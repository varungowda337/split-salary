package com.varun.demo.service;


import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Service;

import com.varun.demo.entity.Expense;
import com.varun.demo.repository.ExpenseRepository;

@Service
public class ExpenseServiceImpl implements ExpenseService {

    private final ExpenseRepository repo;

    public ExpenseServiceImpl(ExpenseRepository repo) {
        this.repo = repo;
    }

    @Override
    public Expense saveExpense(Expense expense) {
        return repo.save(expense);
    }

    @Override
    public List<Expense> getAllExpenses() {
        return repo.findAll();
    }

    @Override
    public Optional<Expense> getExpense(Long id) {
        return repo.findById(id);
    }

    @Override
    public Expense updateExpense(Long id, Expense expense) {
        return repo.findById(id).map(existing -> {
            existing.setName(expense.getName());
            existing.setCategory(expense.getCategory());
            existing.setAmount(expense.getAmount());
            existing.setDate(expense.getDate());
            existing.setNotes(expense.getNotes());
            return repo.save(existing);
        }).orElseThrow(() -> new RuntimeException("Expense not found"));
    }

    @Override
    public void deleteExpense(Long id) {
        repo.deleteById(id);
    }

    @Override
    public List<Expense> getExpensesBetween(LocalDate start, LocalDate end) {
        return repo.findByDateBetween(start, end);
    }
}

