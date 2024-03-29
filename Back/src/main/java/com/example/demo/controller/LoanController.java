package com.example.demo.controller;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Collections;
import java.util.Date;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.mapper.BookMapper;
import com.example.demo.mapper.LoanMapper;
import com.example.demo.mapper.UsersMapper;
import com.example.demo.model.Book;
import com.example.demo.model.Loan;
import com.example.demo.model.Users;
import com.example.demo.util.DateUtil;

@RestController
@RequestMapping("/loan")
public class LoanController {

    private final UsersMapper usersMapper;
    private final BookMapper bookMapper;
    private final LoanMapper loanMapper;

    public LoanController(UsersMapper usersMapper, BookMapper bookMapper, LoanMapper loanMapper) {
        this.usersMapper = usersMapper;
        this.bookMapper = bookMapper;
        this.loanMapper = loanMapper;
    }

    @PostMapping("/create")
    public String createLoan(@RequestParam("user_id") Long user_id, @RequestParam("book_id") String book_id) {
        Users user = usersMapper.getUserProfile(user_id);
        Book book = bookMapper.findByBookId(book_id);

        if (user == null || book == null) {
            return "User or Book not found!";
        }

        Date loanDate = DateUtil.getCurrentDateInKST();
        LocalDate localLoanDate = loanDate.toInstant().atZone(ZoneId.of("Asia/Seoul")).toLocalDate();
        LocalDate expectedReturnDate = localLoanDate.plusDays(14);
        Boolean returnStatus = false;

        Loan loan = new Loan();
        loan.setUser(user);
        loan.setBook(book);
        loan.setLoan_date(loanDate);
        loan.setExpect_date(java.sql.Date.valueOf(expectedReturnDate));
        loan.setReturn_status(returnStatus);

        loanMapper.insertLoan(loan);
        bookMapper.updateBorrowedStatus(book_id, true);
        return "Loan created successfully!";
    }
    
    @GetMapping("/list/{user_id}")
    public ResponseEntity<List<Loan>> getUserLoans(@PathVariable("user_id") Long user_id) {
        List<Loan> userLoans = loanMapper.getLoansByUserId(user_id);
        if (!userLoans.isEmpty()) {
            return ResponseEntity.ok().body(userLoans);
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Collections.emptyList());
        }
    }
    
    @PutMapping("/return/{loan_id}")
    public String returnLoan(@PathVariable("loan_id") Long loan_id) {
        Loan loan = loanMapper.getLoanById(loan_id);

        if (loan == null) {
            return "Loan not found!";
        }

        if (loan.getReturn_status()) {
            return "Loan already returned!";
        }

        Date returnDate = DateUtil.getCurrentDateInKST();
        loan.setReturn_date(returnDate);
        loan.setReturn_status(true);

        loanMapper.returnBook(loan);
        bookMapper.updateBorrowedStatus(loan.getBook().getId(), false);

        return "Book returned successfully!";
    }
    
    @PutMapping("/extend/{loan_id}")
    public ResponseEntity<String> extendLoan(@PathVariable("loan_id") Long loan_id) {
        Loan loan = loanMapper.getLoanById(loan_id);

        if (loan == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("대출을 찾을 수 없습니다!");
        }

        if (loan.getReturn_status()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("이미 반납된 대출입니다!");
        }

        if (loan.getExtend_status()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("대출은 한 번만 연장할 수 있습니다!");
        }

        LocalDate currentLocalDate = loan.getLoan_date().toInstant().atZone(ZoneId.of("Asia/Seoul")).toLocalDate();
        if (currentLocalDate.isEqual(LocalDate.now(ZoneId.of("Asia/Seoul")))) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("대출 당일은 연장할 수 없습니다!");
        }

        LocalDate returnDate = loan.getExpect_date().toInstant().atZone(ZoneId.of("Asia/Seoul")).toLocalDate();
        if (LocalDate.now(ZoneId.of("Asia/Seoul")).isAfter(returnDate)) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("반납예정일 이후에는 연장할 수 없습니다!");
        }

        LocalDate extendedReturnDate = returnDate.plusDays(10);
        loan.setExpect_date(java.sql.Date.valueOf(extendedReturnDate));
        loan.setExtend_status(true);

        loanMapper.extendLoan(loan);

        return ResponseEntity.ok("대출이 성공적으로 연장되었습니다!");
    }
    
    @GetMapping("/expected-dates/{book_id}")
    public ResponseEntity<List<Date>> getExpectedDatesByBookId(@PathVariable("book_id") String book_id) {
        List<Date> expectedDates = loanMapper.getExpectedDatesByBookId(book_id);
        if (!expectedDates.isEmpty()) {
            return ResponseEntity.ok().body(expectedDates);
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(Collections.emptyList());
        }
    }

}