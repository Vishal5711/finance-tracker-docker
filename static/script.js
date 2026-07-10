// Set today's date as default
document.getElementById('date').value = new Date().toISOString().split('T')[0];

// Load data on page load
document.addEventListener('DOMContentLoaded', function() {
    loadSummary();
    loadTransactions();
});

// Add transaction form submission
document.getElementById('transactionForm').addEventListener('submit', function(e) {
    e.preventDefault();
    
    const formData = {
        amount: document.getElementById('amount').value,
        description: document.getElementById('description').value,
        category: document.getElementById('category').value,
        type: document.getElementById('type').value,
        date: document.getElementById('date').value
    };
    
    fetch('/api/transactions', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData)
    })
    .then(response => response.json())
    .then(data => {
        // Reset form
        document.getElementById('transactionForm').reset();
        document.getElementById('date').value = new Date().toISOString().split('T')[0];
        
        // Reload data
        loadSummary();
        loadTransactions();
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Error adding transaction');
    });
});

// Load summary data
function loadSummary() {
    fetch('/api/summary')
        .then(response => response.json())
        .then(data => {
            document.getElementById('income').textContent = `$${data.income.toFixed(2)}`;
            document.getElementById('expenses').textContent = `$${data.expenses.toFixed(2)}`;
            document.getElementById('balance').textContent = `$${data.balance.toFixed(2)}`;
            
            // Color balance based on positive/negative
            const balanceElement = document.getElementById('balance');
            if (data.balance >= 0) {
                balanceElement.style.color = '#28a745';
            } else {
                balanceElement.style.color = '#dc3545';
            }
        })
        .catch(error => {
            console.error('Error loading summary:', error);
        });
}

// Load transactions list
function loadTransactions() {
    fetch('/api/transactions')
        .then(response => response.json())
        .then(data => {
            const transactionsList = document.getElementById('transactionsList');
            
            if (data.length === 0) {
                transactionsList.innerHTML = '<p>No transactions yet. Add your first transaction above!</p>';
                return;
            }
            
            transactionsList.innerHTML = data.map(transaction => `
                <div class="transaction-item">
                    <div class="transaction-details">
                        <strong>${transaction.description}</strong>
                        <span class="transaction-category">${transaction.category}</span>
                        <br>
                        <small>${transaction.date}</small>
                    </div>
                    <div class="transaction-amount ${transaction.type}">
                        ${transaction.type === 'income' ? '+' : '-'}$${transaction.amount.toFixed(2)}
                    </div>
                </div>
            `).join('');
        })
        .catch(error => {
            console.error('Error loading transactions:', error);
        });
}
