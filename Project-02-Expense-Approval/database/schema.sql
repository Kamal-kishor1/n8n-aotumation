CREATE TABLE expenses (
 id SERIAL PRIMARY KEY,
 employee_name VARCHAR(100),
 department VARCHAR(100),
 expense_type VARCHAR(100),
 amount DECIMAL(10,2),
 description TEXT,
 status VARCHAR(50),
 approval_type VARCHAR(50),
 approved_by VARCHAR(100),
 rejection_reason TEXT,
 created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
