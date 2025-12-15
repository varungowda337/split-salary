package com.varun.demo.repository;


import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.varun.demo.entity.Salary;



@Repository
public interface SalaryRepository extends JpaRepository<Salary, Long> {
}

