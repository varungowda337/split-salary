package com.varun.demo.controller;


import java.time.LocalDate;
import java.util.List;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.varun.demo.entity.Expense;
import com.varun.demo.entity.Salary;
import com.varun.demo.repository.SalaryRepository;
import com.varun.demo.service.ExpenseService;

@Controller
public class ExpenseController {

    private final ExpenseService expenseService;
    private final SalaryRepository salaryRepository;

    public ExpenseController(ExpenseService expenseService, SalaryRepository salaryRepository) {
        this.expenseService = expenseService;
        this.salaryRepository = salaryRepository;
    }

    // Serve dashboard page
    @GetMapping({"/", "/dashboard"})
    public String dashboard(Model model) {
        List<Expense> all = expenseService.getAllExpenses();
        model.addAttribute("expenses", all);

        // load salary (if no row, create with 0)
        Salary salary = salaryRepository.findAll().stream().findFirst().orElseGet(() -> salaryRepository.save(new Salary(0.0)));
        model.addAttribute("salary", salary.getMonthly());

        return "dashboard";
    }

    // REST endpoints (JSON) for frontend AJAX

    @GetMapping("/api/expenses")
    @ResponseBody
    public List<Expense> getExpenses() {
        return expenseService.getAllExpenses();
    }

    @PostMapping("/api/expenses")
    @ResponseBody
    public Expense createExpense(@RequestBody Expense expense) {
        return expenseService.saveExpense(expense);
    }

    @PutMapping("/api/expenses/{id}")
    @ResponseBody
    public Expense updateExpense(@PathVariable Long id, @RequestBody Expense expense) {
        return expenseService.updateExpense(id, expense);
    }

    @DeleteMapping("/api/expenses/{id}")
    @ResponseBody
    public void deleteExpense(@PathVariable Long id) {
        expenseService.deleteExpense(id);
    }

    // Salary update via AJAX
    @PostMapping("/api/salary")
    @ResponseBody
    public Salary setSalary(@RequestParam Double monthly) {
        Salary salary = salaryRepository.findAll().stream().findFirst().orElse(new Salary());
        salary.setMonthly(monthly);
        return salaryRepository.save(salary);
    }

    // optional: get expenses between dates
    @GetMapping("/api/expenses/range")
    @ResponseBody
    public List<Expense> getRange(@RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate start,
                                  @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate end) {
        return expenseService.getExpensesBetween(start, end);
    }
}

