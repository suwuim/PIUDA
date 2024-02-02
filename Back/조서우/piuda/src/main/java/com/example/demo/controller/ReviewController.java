package com.example.demo.controller;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.example.demo.mapper.LoanMapper;
import com.example.demo.mapper.ReviewMapper;
import com.example.demo.mapper.UsersMapper;
import com.example.demo.model.Loan;
import com.example.demo.model.Review;
import com.example.demo.model.Users;

@RestController
@RequestMapping("/api/review")
public class ReviewController {
    private final LoanMapper loanMapper;
    private final ReviewMapper reviewMapper;


    public ReviewController(LoanMapper loanMapper, ReviewMapper reviewMapper, UsersMapper usersMapper) {
        this.loanMapper = loanMapper;
        this.reviewMapper = reviewMapper;
    }
    
    @GetMapping("/get/isbn/by-loan/{loanId}")
    public ResponseEntity<?> getIsbnByLoanId(@PathVariable("loanId") Long loanId) {
        String isbn = loanMapper.getIsbnByLoanId(loanId);
        if (isbn != null) {
            return ResponseEntity.ok(isbn);
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("ISBN not found for the given loan ID");
        }
    }
    
    @GetMapping("/get/by-isbn/{isbn}")
    public ResponseEntity<?> getReviewsWithUserNameByIsbn(@PathVariable("isbn") String isbn) {
        List<Review> reviews = reviewMapper.getReviewsByIsbn(isbn);

        if (reviews != null && !reviews.isEmpty()) {
            return ResponseEntity.ok(reviews);
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("No reviews found for this ISBN");
        }
    }



    @PostMapping("/add")
    public ResponseEntity<?> insertReview(@RequestParam("loan_id") Long loan_id, @RequestParam("review_text") String review_text) {
        Loan loan = loanMapper.getLoanById(loan_id);

        if (loan != null) {
            // 리뷰를 작성하고 리뷰 객체를 생성
            Review review = new Review();
            review.setLoan(loan);
            review.setReview_content(review_text);

            // 사용자 이름 설정
            Users user = loan.getUser();
            if (user != null) {
                review.setUser_name(user.getName());
            } else {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to add review: User not found");
            }

            // 리뷰를 데이터베이스에 저장
            reviewMapper.insertReview(review);

            return ResponseEntity.ok().body("Review added successfully");
        } else {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to add review: Loan not found");
        }
    }

    @DeleteMapping("/remove/{review_id}")
    public ResponseEntity<?> removeReview(@PathVariable("review_id") Long review_id) {
        // 리뷰를 삭제하고 삭제 여부를 확인
        int deletedRows = reviewMapper.deleteReview(review_id);

        if (deletedRows > 0) {
            return ResponseEntity.ok().body("Review removed successfully");
        } else {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Failed to remove review");
        }
    }
}