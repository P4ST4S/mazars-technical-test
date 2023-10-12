// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract Library {
    address owner; // < This variable stores the address of the owner of the contract.
    uint public bookCount; // < This variable stores the number of books in the library.
    bool isOpened; // < This variable stores whether the library is opened or not.

    /**
     * @dev Struct representing a book in the library.
     * @param title The title of the book.
     * @param author The author of the book.
     * @param available Whether the book is available for borrowing.
     * @param borrower The address of the borrower, if the book is currently borrowed.
     */
    struct book {
        string title;
        string author;
        bool available;
        address borrower;
    }

    string[] availableBooks; // < This array stores the titles of the books that are available for borrowing.
    mapping(string => book) Books; // < This mapping stores the books in the library.

    /**
     * @dev Constructor of the contract.
     * @notice Sets the owner of the contract.
     */
    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Modifier that checks if the sender is the owner of the contract.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do that");
        _;
    }

    /**
     * @dev Modifier that checks if the library is opened.
     */
    modifier libraryIsOpened() {
        require(isOpened, "Library isn't opened");
        _;
    }

    event BookAdded(string title); // < This event is emitted when a book is added to the library.
    event BookBorrowed(string title, address borrower); // < This event is emitted when a book is borrowed.
    event BookReturned(string title); // < This event is emitted when a book is returned.
    event BookRemoved(string title); // < This event is emitted when a book is removed from the library.

    /**
     * @dev Returns an array of available books.
     * @return An array of strings representing the available books.
     */
    function getAvailableBooks() public view libraryIsOpened returns(string[] memory) {
        return availableBooks;
    }

    /**
     * @dev Adds a new book to the library.
     * @param _title The title of the book to be added.
     * @param _author The author of the book to be added.
     * Emits a BookAdded event when the book is successfully added.
     * Requirements:
     * - The title and author of the book must not be empty strings.
     * - The book must not already exist in the library.
     * - Only the owner of the library can add a new book.
     */
    function addBook(string memory _title, string memory _author) public onlyOwner {
        require(bytes(_title).length > 0, "You must enter a title for the book");
        require(bytes(_author).length > 0, "You must enter an author for the book");
        require(!Books[_title].available || Books[_title].borrower != address(0), "This book already exist");
        bookCount++;
        Books[_title] = book(_title, _author, true, address(0));
        availableBooks.push(_title);
        emit BookAdded(_title);
    }

    /**
     * @dev Removes a book from the availableBooks array and sets its availability to false.
     * @param _title The title of the book to be removed.
     */
    function removeBookOfArray(string memory _title) private libraryIsOpened {
        string[] memory newAvailableBooks = new string[](availableBooks.length - 1);
        uint newAvailableBooksIndex = 0;

        uint len = availableBooks.length;
        Books[_title].available = false;
        for(uint i = 0; i < len; i++) {
            if (Books[availableBooks[i]].available) {
                newAvailableBooks[newAvailableBooksIndex] = availableBooks[i];
                newAvailableBooksIndex++;
            }
        }
        delete availableBooks;
        availableBooks = newAvailableBooks;
    }

    /**
     * @dev Allows a user to borrow a book from the library.
     * @param _title The title of the book to borrow.
     */
    function borrowBook(string memory _title) public libraryIsOpened {
        require(Books[_title].available, "This book is unavailable");
        Books[_title].borrower = msg.sender;

        removeBookOfArray(_title);

        emit BookBorrowed(_title, msg.sender);
    }

    /**
     * @dev Allows the borrower to return a book to the library.
     * @param _title The title of the book to be returned.
     * Requirements:
     * - The library must be opened.
     * - The borrower must be the one returning the book.
     * - The book must have been borrowed by the borrower.
     */
    function returnBook(string memory _title) public libraryIsOpened {
        require(Books[_title].borrower == msg.sender, "You don't have this book");
        Books[_title].available = true;
        availableBooks.push(_title);
    }

    /**
     * @dev Removes a book from the library.
     * @param _title The title of the book to be removed.
     * Emits a `BookRemoved` event.
     */
    function removeBook(string memory _title) public libraryIsOpened {
        require(bytes(Books[_title].title).length > 0, "This book doesn't exist");
        bookCount--;
        delete Books[_title];

        removeBookOfArray(_title);

        emit BookRemoved(_title);
    }

    /**
     * @dev Toggles the state of the library between opened and closed.
     * Can only be called by the contract owner.
     */
    function toggleLibrary() public onlyOwner {
        isOpened = !isOpened;
    }
}
