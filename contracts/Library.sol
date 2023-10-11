// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract Library {
    address public owner;

    struct book {
        string title;
        address borrower;
        bool available;
    }

    mapping(string => book) Books;
    uint public bookCount;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    event BookAdded(string title);
    event BookBorrowed(string title, address borrower);
    event BookReturned(string title);
    event BookRemoved(string title);

    function addBook(string memory _title) public onlyOwner {
        bookCount++;
        Books[_title] = book(_title, address(0), true);
        emit BookAdded(_title);
    }

    function borrowBook(string calldata _title) public {
        require(bytes(Books[_title].title).length > 0, "This book doesn't exist");
        require(Books[_title].available, "This book is not available for borrowing");

        Books[_title].borrower = msg.sender;
        Books[_title].available = false;
        emit BookBorrowed(_title, msg.sender);
    }

    function returnBook(string calldata _title) public {
        require(bytes(Books[_title].title).length > 0, "This book doesn't exist");
        require(Books[_title].borrower == msg.sender, "You didn't borrow this book");

        Books[_title].borrower = address(0);
        Books[_title].available = true;
        emit BookReturned(_title);
    }

    function removeBook(string calldata _title) public onlyOwner {
        require(bytes(Books[_title].title).length > 0, "This book doesn't exist");
        bookCount--;
        delete Books[_title];
        emit BookRemoved(_title);
    }
}
