package com.varun.demo.service;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import com.varun.demo.entity.Expense;

public interface ExpenseService {

    Expense saveExpense(Expense expense);
    List<Expense> getAllExpenses();
    Optional<Expense> getExpense(Long id);
    Expense updateExpense(Long id, Expense expense);
    void deleteExpense(Long id);

    List<Expense> getExpensesBetween(LocalDate start, LocalDate end);
}

