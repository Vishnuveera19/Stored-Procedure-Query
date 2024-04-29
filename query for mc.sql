CREATE PROCEDURE CalculateMonthlySalaryForMonthYear 
    @Year INT, -- Year for which salary calculation is needed
    @Month INT -- Month for which salary calculation is needed
AS
BEGIN
    -- Step 1: Calculate the number of working days for each employee within the specified month and year
    SELECT 
        pn_employeeId,
        COUNT(DISTINCT CAST(intime AS DATE)) AS working_days
    INTO #EmployeeAttendance -- Temporary table to store employee attendance data
    FROM 
        attendance
    WHERE 
        YEAR(intime) = @Year
        AND MONTH(intime) = @Month
        AND day_status = 'Present' -- Considering only the records where the employee was present
    GROUP BY 
        pn_employeeId;

    -- Step 2: Execute the stored procedure for each employee
    DECLARE @EmployeeId INT;
    DECLARE @BasicPay DECIMAL(10, 2) = 15000; -- Basic pay
    DECLARE @DA DECIMAL(5, 4) = 0.04; -- DA percentage
    DECLARE @LeaveWithoutPay INT = 0; -- Assuming leave without pay is not considered for now
    DECLARE @HRA DECIMAL(5, 4) = 0.04; -- HRA percentage
    DECLARE @LTA_Pct DECIMAL(5, 4) = 0.05; -- Leave Travel Allowance as percentage
    DECLARE @MedReimbursement_Pct DECIMAL(5, 4) = 0.02; -- Medical Reimbursement as percentage
    DECLARE @Conveyance_Pct DECIMAL(5, 4) = 0.03; -- Conveyance as percentage
    DECLARE @SpecialAllowance_Pct DECIMAL(5, 4) = 0.05; -- Special Allowance as percentage
    DECLARE @CEA_Pct DECIMAL(5, 4) = 0.05; -- Children Education Allowance as percentage
    DECLARE @PF_Pct DECIMAL(5, 4) = 0.12; -- Provident Fund percentage
    DECLARE @ESI_Pct DECIMAL(5, 4) = 0.035; -- Employee State Insurance percentage
    DECLARE @WorkingDaysInMonth INT = 26; -- Working days in the month

    -- Temporary table to store the results
    CREATE TABLE #MonthlySalary (
        EmployeeId INT,
        MonthlySalary DECIMAL(10, 2)
    );

    DECLARE EmployeeCursor CURSOR FOR
    SELECT 
        pn_employeeId
    FROM 
        #EmployeeAttendance;

    OPEN EmployeeCursor;
    FETCH NEXT FROM EmployeeCursor INTO @EmployeeId;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Calculate the monthly salary for the employee
        DECLARE @MonthlySalary DECIMAL(10, 2);

        SELECT @MonthlySalary = ((@BasicPay + (@BasicPay * @DA)) / @WorkingDaysInMonth * (EA.working_days - @LeaveWithoutPay)) 
                        + (@BasicPay * @HRA) 
                        + (@BasicPay * @LTA_Pct) 
                        + (@BasicPay * @MedReimbursement_Pct) 
                        + (@BasicPay * @Conveyance_Pct) 
                        + (@BasicPay * @SpecialAllowance_Pct)
                        + (@BasicPay * @CEA_Pct)
        FROM #EmployeeAttendance EA
        WHERE EA.pn_employeeId = @EmployeeId;

        -- Deduct Provident Fund
        SET @MonthlySalary = @MonthlySalary - (@MonthlySalary * @PF_Pct);

        -- Deduct Employee State Insurance
        SET @MonthlySalary = @MonthlySalary - (@MonthlySalary * @ESI_Pct);

        -- Insert the result into the temporary table
        INSERT INTO #MonthlySalary (EmployeeId, MonthlySalary) VALUES (@EmployeeId, @MonthlySalary);

        FETCH NEXT FROM EmployeeCursor INTO @EmployeeId;
    END;

    CLOSE EmployeeCursor;
    DEALLOCATE EmployeeCursor;

    
    SELECT 
        'Employee ' + CAST(EmployeeId AS VARCHAR(10)) + ' Monthly Salary for ' + CAST(@Month AS VARCHAR(2)) + '/' + CAST(@Year AS VARCHAR(4)) AS EmployeeInfo,
        MonthlySalary
    FROM 
        #MonthlySalary;

    
    DROP TABLE #EmployeeAttendance;
    DROP TABLE #MonthlySalary;
END;

GO

EXEC CalculateMonthlySalaryForMonthYear @Year = 2015, @Month = 5;


GO 

Select * from attendance

GO 

drop procedure CalculateMonthlySalaryForMonthYear
