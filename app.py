from flask import Flask, render_template, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from datetime import datetime
import os

app = Flask(__name__)
CORS(app)

# Database configuration
app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL', 
    'mysql+pymysql://root:password@localhost/finance_db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# Simple Transaction Model
class Transaction(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    amount = db.Column(db.Float, nullable=False)
    description = db.Column(db.String(200), nullable=False)
    category = db.Column(db.String(50), nullable=False)
    type = db.Column(db.String(10), nullable=False)  # income or expense
    date = db.Column(db.Date, nullable=False, default=datetime.utcnow)

# Routes
@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/transactions', methods=['GET'])
def get_transactions():
    transactions = Transaction.query.order_by(Transaction.date.desc()).all()
    return jsonify([{
        'id': t.id,
        'amount': t.amount,
        'description': t.description,
        'category': t.category,
        'type': t.type,
        'date': t.date.strftime('%Y-%m-%d')
    } for t in transactions])

@app.route('/api/transactions', methods=['POST'])
def add_transaction():
    try:
        data = request.json
        print(f"Received data: {data}")  # Debug log
        
        transaction = Transaction(
            amount=float(data['amount']),
            description=data['description'],
            category=data['category'],
            type=data['type'],
            date=datetime.strptime(data['date'], '%Y-%m-%d').date()
        )
        db.session.add(transaction)
        db.session.commit()
        
        print(f"Transaction saved with ID: {transaction.id}")  # Debug log
        return jsonify({'message': 'Transaction added successfully', 'id': transaction.id})
    except Exception as e:
        print(f"Error saving transaction: {e}")  # Debug log
        return jsonify({'error': str(e)}), 500

@app.route('/api/summary')
def get_summary():
    income = db.session.query(db.func.sum(Transaction.amount)).filter_by(type='income').scalar() or 0
    expenses = db.session.query(db.func.sum(Transaction.amount)).filter_by(type='expense').scalar() or 0
    balance = income - expenses
    
    return jsonify({
        'income': income,
        'expenses': expenses,
        'balance': balance
    })

@app.route('/api/debug')
def debug_db():
    try:
        # Count total transactions
        total_count = Transaction.query.count()
        
        # Get all transactions with details
        transactions = Transaction.query.all()
        
        return jsonify({
            'status': 'MySQL Database connected successfully',
            'total_transactions': total_count,
            'database_type': 'MySQL',
            'database_name': 'finance_db',
            'all_transactions': [{
                'id': t.id,
                'amount': t.amount,
                'description': t.description,
                'category': t.category,
                'type': t.type,
                'date': t.date.strftime('%Y-%m-%d')
            } for t in transactions]
        })
    except Exception as e:
        return jsonify({
            'status': 'Database error',
            'error': str(e)
        })

# Initialize database
def create_tables():
    with app.app_context():
        db.create_all()

if __name__ == '__main__':
    create_tables()
    app.run(host='0.0.0.0', port=5000, debug=False)
