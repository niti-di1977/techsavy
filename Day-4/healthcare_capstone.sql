-- ---------------------------------------------------
-- Sprint 1: ERD & Schema Design for Healthcare Diagnostics
-- ---------------------------------------------------

-- 1. Branch Table
CREATE TABLE Branch (
    branch_id      NUMBER PRIMARY KEY,
    branch_name    VARCHAR2(100) NOT NULL,
    location       VARCHAR2(150),
    contact_no     VARCHAR2(15)
);

-- 2. Department Table
CREATE TABLE Department (
    dept_id        NUMBER PRIMARY KEY,
    dept_name      VARCHAR2(100) NOT NULL,
    branch_id      NUMBER REFERENCES Branch(branch_id)
);

-- 3. Doctor Table
CREATE TABLE Doctor (
    doctor_id      NUMBER PRIMARY KEY,
    doctor_name    VARCHAR2(100) NOT NULL,
    specialization VARCHAR2(100),
    dept_id        NUMBER REFERENCES Department(dept_id)
);

-- 4. Patient Table
CREATE TABLE Patient (
    patient_id     NUMBER PRIMARY KEY,
    patient_name   VARCHAR2(100) NOT NULL,
    dob            DATE,
    gender         VARCHAR2(10),
    contact_no     VARCHAR2(15),
    email          VARCHAR2(100)
);

-- 5. Visit Table
CREATE TABLE Visit (
    visit_id       NUMBER PRIMARY KEY,
    patient_id     NUMBER REFERENCES Patient(patient_id),
    doctor_id      NUMBER REFERENCES Doctor(doctor_id),
    visit_date     DATE DEFAULT SYSDATE,
    reason         VARCHAR2(255)
);

-- 6. Test Table
CREATE TABLE Test (
    test_id        NUMBER PRIMARY KEY,
    test_name      VARCHAR2(100) NOT NULL,
    price          NUMBER(8,2)
);

-- 7. Test Package Table
CREATE TABLE Test_Package (
    package_id     NUMBER PRIMARY KEY,
    package_name   VARCHAR2(100),
    total_price    NUMBER(8,2)
);

-- 8. Package_Test Junction Table
CREATE TABLE Package_Test (
    package_id     NUMBER REFERENCES Test_Package(package_id),
    test_id        NUMBER REFERENCES Test(test_id),
    PRIMARY KEY (package_id, test_id)
);

-- 9. Test_Report Table
CREATE TABLE Test_Report (
    report_id      NUMBER PRIMARY KEY,
    visit_id       NUMBER REFERENCES Visit(visit_id),
    test_id        NUMBER REFERENCES Test(test_id),
    result         VARCHAR2(100),
    report_date    DATE DEFAULT SYSDATE
);

-- 10. Technician Table
CREATE TABLE Technician (
    technician_id  NUMBER PRIMARY KEY,
    technician_name VARCHAR2(100),
    branch_id      NUMBER REFERENCES Branch(branch_id)
);

-- 11. Inventory Table
CREATE TABLE Inventory (
    item_id        NUMBER PRIMARY KEY,
    item_name      VARCHAR2(100),
    quantity       NUMBER,
    last_updated   DATE DEFAULT SYSDATE,
    branch_id      NUMBER REFERENCES Branch(branch_id)
);

-- 12. Bill Table
CREATE TABLE Bill (
    bill_id        NUMBER PRIMARY KEY,
    visit_id       NUMBER REFERENCES Visit(visit_id),
    total_amount   NUMBER(10,2),
    discount       NUMBER(5,2),
    net_amount     NUMBER(10,2),
    billing_date   DATE DEFAULT SYSDATE
);

-- ---------------------------------------------------
-- Sprint 2: Sample PL/SQL Packages and Procedures
-- ---------------------------------------------------

-- 1. Procedure to Register New Patient
CREATE OR REPLACE PROCEDURE add_patient(
    p_id         NUMBER,
    p_name       VARCHAR2,
    p_dob        DATE,
    p_gender     VARCHAR2,
    p_contact    VARCHAR2,
    p_email      VARCHAR2
) AS
BEGIN
    INSERT INTO Patient(patient_id, patient_name, dob, gender, contact_no, email)
    VALUES(p_id, p_name, p_dob, p_gender, p_contact, p_email);
END;
/

-- 2. Function to calculate net bill
CREATE OR REPLACE FUNCTION calculate_net_amount(
    total NUMBER,
    discount NUMBER
) RETURN NUMBER IS
BEGIN
    RETURN total - (total * discount / 100);
END;
/

-- 3. Procedure to Generate Bill
CREATE OR REPLACE PROCEDURE generate_bill(
    p_bill_id     NUMBER,
    p_visit_id    NUMBER,
    p_total       NUMBER,
    p_discount    NUMBER
) AS
    v_net NUMBER;
BEGIN
    v_net := calculate_net_amount(p_total, p_discount);
    INSERT INTO Bill(bill_id, visit_id, total_amount, discount, net_amount)
    VALUES(p_bill_id, p_visit_id, p_total, p_discount, v_net);
END;
/

-- ---------------------------------------------------
-- Sprint 3: Reports & Analytics
-- ---------------------------------------------------

-- 1. List of patients with visit count
SELECT p.patient_name, COUNT(v.visit_id) AS visit_count
FROM Patient p
JOIN Visit v ON p.patient_id = v.patient_id
GROUP BY p.patient_name;

-- 2. Total Revenue by Branch
SELECT b.branch_name, SUM(bill.net_amount) AS total_revenue
FROM Branch b
JOIN Department d ON b.branch_id = d.branch_id
JOIN Doctor doc ON d.dept_id = doc.dept_id
JOIN Visit v ON doc.doctor_id = v.doctor_id
JOIN Bill bill ON v.visit_id = bill.visit_id
GROUP BY b.branch_name;

-- 3. Procedure: Inventory Alert
CREATE OR REPLACE PROCEDURE inventory_alert IS
BEGIN
    FOR item IN (SELECT item_name, quantity FROM Inventory WHERE quantity < 10)
    LOOP
        DBMS_OUTPUT.PUT_LINE('Low Stock: ' || item.item_name || ' - Qty: ' || item.quantity);
    END LOOP;
END;
/
