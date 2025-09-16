/*Use this connection to test permissions:

----SELECT * FROM Accounts; (should work)

----SELECT * FROM Loans; (should give error if not granted)

----- UPDATE Accounts SET balance = 6000 WHERE account_id = 1001; (depends on grants)*/