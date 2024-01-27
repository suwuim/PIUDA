package com.example.demo.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Result;
import org.apache.ibatis.annotations.Results;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.One;

import com.example.demo.model.Book;
import com.example.demo.model.UserInterestBook;
import com.example.demo.model.Users;

@Mapper
public interface UserInterestBookMapper {
    
    @Insert("INSERT INTO UserInterestBook (user_id, book_id) VALUES (#{user.id}, #{book.id})")
    int insertUserInterestBook(@Param("user") Users user, @Param("book") Book book);

    @Delete("DELETE FROM UserInterestBook WHERE user_id=#{user.id} AND book_id=#{book.id}")
    int deleteUserInterestBook(@Param("user") Users user, @Param("book") Book book);
    
    @Select("SELECT * FROM UserInterestBook WHERE user_id=#{user_id}")
    @Results({
            @Result(property = "user", column = "user_id", javaType = Users.class, one = @One(select = "com.example.demo.mapper.UsersMapper.getUserProfile")),
            @Result(property = "book", column = "book_id", javaType = Book.class, one = @One(select = "com.example.demo.mapper.BookMapper.findByBookId"))
    })
    List<UserInterestBook> getUserInterestList(@Param("user_id") Long user_id);
}