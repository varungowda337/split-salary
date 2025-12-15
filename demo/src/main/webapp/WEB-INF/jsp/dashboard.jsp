<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>SplitSalary Dashboard</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Tailwind -->
    <script src="https://cdn.tailwindcss.com"></script>

    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        body {
            font-family: Inter, system-ui, -apple-system, "Segoe UI", Roboto, Arial;
        }
    </style>
</head>

<body class="bg-gradient-to-br from-slate-50 to-indigo-50 min-h-screen p-6">

<div class="max-w-6xl mx-auto">

    <!-- Header -->
    <div class="flex justify-between items-center mb-8">
        <h1 class="text-3xl font-extrabold text-indigo-700 tracking-tight">
            SplitSalary
        </h1>

        <div class="flex items-center gap-3 bg-white p-3 rounded-xl shadow">
            <label class="text-sm text-gray-600">Monthly Salary</label>
            <input
                id="salaryInput"
                type="number"
                class="w-36 px-3 py-2 border rounded-lg focus:ring-2 focus:ring-indigo-500"
                value="<c:out value='${salary}' default='0'/>"
            >
            <button
                id="saveSalaryBtn"
                class="px-4 py-2 bg-indigo-600 hover:bg-indigo-700 text-white rounded-lg transition">
                Save
            </button>
        </div>
    </div>

    <!-- Summary -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div class="bg-white p-5 rounded-xl shadow hover:shadow-lg transition">
            <div class="text-sm text-gray-500">Salary</div>
            <div id="salaryCard" class="text-2xl font-bold text-green-600 mt-1">₹ 0</div>
        </div>

        <div class="bg-white p-5 rounded-xl shadow hover:shadow-lg transition">
            <div class="text-sm text-gray-500">Total Expenses</div>
            <div id="expensesCard" class="text-2xl font-bold text-red-600 mt-1">₹ 0</div>
        </div>

        <div class="bg-white p-5 rounded-xl shadow hover:shadow-lg transition">
            <div class="text-sm text-gray-500">Savings</div>
            <div id="savingsCard" class="text-2xl font-bold text-blue-600 mt-1">₹ 0</div>
        </div>
    </div>

    <!-- Charts -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
        <div class="lg:col-span-2 bg-white p-6 rounded-xl shadow">
            <h2 class="font-semibold text-lg mb-3 text-slate-700">
                Monthly Expenses by Category
            </h2>
            <canvas id="barChart" height="140"></canvas>
        </div>

        <div class="bg-white p-6 rounded-xl shadow">
            <h2 class="font-semibold text-lg mb-3 text-slate-700">
                Category Share
            </h2>
            <canvas id="pieChart" height="220"></canvas>
        </div>
    </div>

    <!-- Add Expense -->
    <div class="bg-white p-6 rounded-xl shadow mb-8">
        <h2 class="font-semibold text-lg mb-4 text-slate-700">Add Expense</h2>

        <form id="addExpenseForm" class="grid grid-cols-1 md:grid-cols-4 gap-4">
            <input id="name" placeholder="Expense Title" class="px-3 py-2 border rounded-lg" required>
            <input id="amount" type="number" placeholder="Amount" class="px-3 py-2 border rounded-lg" required>

            <select id="category" class="px-3 py-2 border rounded-lg">
                <option>Food</option>
                <option>Housing</option>
                <option>Transport</option>
                <option>Utilities</option>
                <option>Health</option>
                <option>Entertainment</option>
                <option>Shopping</option>
                <option>Other</option>
            </select>

            <input id="date" type="date" class="px-3 py-2 border rounded-lg">

            <input id="notes" placeholder="Notes (optional)"
                   class="md:col-span-4 px-3 py-2 border rounded-lg">

            <div class="md:col-span-4 text-right">
                <button type="submit"
                        class="px-6 py-2 bg-green-600 hover:bg-green-700 text-white rounded-lg transition">
                    Add Expense
                </button>
            </div>
        </form>
    </div>

    <!-- Expense Table -->
    <div class="bg-white p-6 rounded-xl shadow">
        <h2 class="font-semibold text-lg mb-4 text-slate-700">All Expenses</h2>

        <div class="overflow-x-auto">
            <table class="w-full text-sm border-separate border-spacing-y-2">
                <thead>
                <tr class="text-left text-gray-500">
                    <th>Category</th>
                    <th>Amount</th>
                    <th>Date</th>
                    <th>Notes</th>
                    <th class="text-right">Actions</th>
                </tr>
                </thead>
                <tbody id="expensesTbody"></tbody>
            </table>
        </div>
    </div>

</div>

<!-- ================= JAVASCRIPT ================= -->
<script>
    function escapeHtml(str) {
        if (!str) return '';
        return String(str)
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#039;');
    }

    const currency = new Intl.NumberFormat('en-IN', {
        style: 'currency',
        currency: 'INR',
        maximumFractionDigits: 0
    });

    function fmt(v) {
        return currency.format(Number(v || 0));
    }

    const salaryInput = document.getElementById('salaryInput');
    const salaryCard = document.getElementById('salaryCard');
    const expensesCard = document.getElementById('expensesCard');
    const savingsCard = document.getElementById('savingsCard');
    const expensesTbody = document.getElementById('expensesTbody');

    let expenses = [];
    let barChart = null;
    let pieChart = null;

    async function loadExpenses() {
        const res = await fetch('/api/expenses');
        expenses = await res.json();

        const salary = Number(salaryInput.value || 0);
        let total = 0;
        expenses.forEach(e => total += Number(e.amount || 0));

        salaryCard.innerText = fmt(salary);
        expensesCard.innerText = fmt(total);
        savingsCard.innerText = fmt(salary - total);

        renderTable();
        renderCharts();
    }

    function renderTable() {
        expensesTbody.innerHTML = '';

        expenses.forEach(function (e) {
            const tr = document.createElement('tr');
            tr.className = 'bg-slate-50 hover:bg-indigo-50 transition rounded-lg';

            tr.innerHTML =
                '<td class="py-2 px-2 font-medium">' + escapeHtml(e.category) + '</td>' +
                '<td class="font-semibold text-red-600">' + fmt(e.amount) + '</td>' +
                '<td>' + escapeHtml(e.date) + '</td>' +
                '<td>' + escapeHtml(e.notes || '') + '</td>' +
                '<td class="text-right">' +
                    '<button class="text-red-600 hover:text-red-800 font-medium" ' +
                    'onclick="deleteExpense(' + e.id + ')">Delete</button>' +
                '</td>';

            expensesTbody.appendChild(tr);
        });
    }

    function renderCharts() {
        const now = new Date();
        const month = now.getMonth();
        const year = now.getFullYear();

        const categoryMap = {};

        expenses.forEach(function (e) {
            if (!e.date) return;
            const d = new Date(e.date);
            if (d.getMonth() === month && d.getFullYear() === year) {
                const c = e.category || 'Other';
                categoryMap[c] = (categoryMap[c] || 0) + Number(e.amount || 0);
            }
        });

        const labels = Object.keys(categoryMap);
        const values = labels.map(l => categoryMap[l]);

        const colors = [
            '#6366f1', '#22c55e', '#ef4444', '#f59e0b',
            '#06b6d4', '#8b5cf6', '#ec4899', '#64748b'
        ];

        const barCtx = document.getElementById('barChart').getContext('2d');
        if (barChart) barChart.destroy();

        barChart = new Chart(barCtx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    data: values,
                    backgroundColor: colors
                }]
            },
            options: {
                responsive: true,
                plugins: { legend: { display: false } }
            }
        });

        const pieCtx = document.getElementById('pieChart').getContext('2d');
        if (pieChart) pieChart.destroy();

        pieChart = new Chart(pieCtx, {
            type: 'pie',
            data: {
                labels: labels,
                datasets: [{
                    data: values,
                    backgroundColor: colors
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: { position: 'bottom' }
                }
            }
        });
    }

    async function deleteExpense(id) {
        if (!confirm('Delete this expense?')) return;
        await fetch('/api/expenses/' + id, { method: 'DELETE' });
        loadExpenses();
    }

    document.getElementById('addExpenseForm').addEventListener('submit', async function (e) {
        e.preventDefault();

        const payload = {
            name: name.value,
            amount: amount.value,
            category: category.value,
            date: date.value,
            notes: notes.value
        };

        await fetch('/api/expenses', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        e.target.reset();
        loadExpenses();
    });

    document.getElementById('saveSalaryBtn').addEventListener('click', async function () {
        await fetch('/api/salary?monthly=' + salaryInput.value, { method: 'POST' });
        loadExpenses();
    });

    loadExpenses();
</script>

</body>
</html>
