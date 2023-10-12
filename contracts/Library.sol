// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract Library {
    address owner;
    uint public bookCount;

    struct book {
        string title;
        string author;
        bool available;
        address borrower;
    }

    string[] availableBooks;
    mapping(string => book) Books;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do that");
        _;
    }

    event BookAdded(string title);
    event BookBorrowed(string title, address borrower);
    event BookReturned(string title);
    event BookRemoved(string title);

    function getAvailableBooks() public view returns(string[] memory) {
        return availableBooks;
    }

    function addBook(string memory _title, string memory _author) public onlyOwner {
        require(bytes(_title).length > 0, "You must enter a title for the book");
        require(bytes(_author).length > 0, "You must enter an author for the book");
        require(!Books[_title].available || Books[_title].borrower != address(0), "This book already exist");
        bookCount++;
        Books[_title] = book(_title, _author, true, address(0));
        availableBooks.push(_title);
        emit BookAdded(_title);
    }

    function borrowBook(string memory _title) public {
        require(Books[_title].available, "This book is unavailable");
        Books[_title].borrower = msg.sender;

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
}
