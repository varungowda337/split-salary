package com.varun.demo.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "salary")
public class Salary {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Double monthly;

    public Salary() {}

    public Salary(Double monthly) {
        this.monthly = monthly;
    }

    // getters & setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Double getMonthly() { return monthly; }
    public void setMonthly(Double monthly) { this.monthly = monthly; }
}

