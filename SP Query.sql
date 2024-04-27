CREATE PROCEDURE CalculateMonthlySalary 
    @BasicPay DECIMAL(10, 2),
    @DA DECIMAL(5, 4),
    @LeaveWithoutPay INT,
    @HRA DECIMAL(5, 4),
    @LTA_Pct DECIMAL(5, 4), -- Leave Travel Allowance as percentage
    @MedReimbursement_Pct DECIMAL(5, 4), -- Medical Reimbursement as percentage
    @Conveyance_Pct DECIMAL(5, 4), -- Conveyance as percentage
    @SpecialAllowance_Pct DECIMAL(5, 4), -- Special Allowance as percentage
    @CEA_Pct DECIMAL(5, 4), -- Children Education Allowance as percentage
    @PF_Pct DECIMAL(5, 4), -- Provident Fund percentage
    @ESI_Pct DECIMAL(5, 4), -- Employee State Insurance percentage
    @WorkingDaysInMonth INT
AS
BEGIN
    DECLARE @LTA DECIMAL(10, 2);
    DECLARE @MedReimbursement DECIMAL(10, 2);
    DECLARE @Conveyance DECIMAL(10, 2);
    DECLARE @SpecialAllowance DECIMAL(10, 2);
    DECLARE @CEA DECIMAL(10, 2); -- Children Education Allowance
    DECLARE @GrossSalary DECIMAL(10, 2);
    DECLARE @PF DECIMAL(10, 2); -- Provident Fund deduction
    DECLARE @ESI DECIMAL(10, 2); -- Employee State Insurance deduction
    DECLARE @MonthlySalary DECIMAL(10, 2);

    -- Calculate LTA based on the percentage
    SET @LTA = @BasicPay * @LTA_Pct;

    -- Calculate Medical Reimbursement based on the percentage
    SET @MedReimbursement = @BasicPay * @MedReimbursement_Pct;

    -- Calculate Conveyance based on the percentage
    SET @Conveyance = @BasicPay * @Conveyance_Pct;

    -- Calculate Special Allowance based on the percentage
    SET @SpecialAllowance = @BasicPay * @SpecialAllowance_Pct;

    -- Calculate CEA based on the percentage
    SET @CEA = @BasicPay * @CEA_Pct;

    -- Calculate the Gross Salary including all allowances
    SET @GrossSalary = ((@BasicPay + (@BasicPay * @DA)) / @WorkingDaysInMonth * (@WorkingDaysInMonth - @LeaveWithoutPay)) 
                        + (@BasicPay * @HRA) 
                        + @LTA 
                        + @MedReimbursement 
                        + @Conveyance 
                        + @SpecialAllowance
                        + @CEA;

    -- Calculate Provident Fund deduction
    SET @PF = @GrossSalary * @PF_Pct;

    -- Calculate Employee State Insurance deduction
    SET @ESI = @GrossSalary * @ESI_Pct;

    -- Calculate the monthly salary after deductions
    SET @MonthlySalary = @GrossSalary - @PF - @ESI;

    -- Return the calculated monthly salary
    SELECT @MonthlySalary AS MonthlySalary;
END;

GO

-- Execute the stored procedure with the provided parameters including allowances as percentages
DECLARE @BasicPay DECIMAL(10, 2) = 15000; -- Basic pay
DECLARE @DA DECIMAL(5, 4) = 0.04; -- DA percentage
DECLARE @LeaveWithoutPay INT = 3; -- Leave days without pay
DECLARE @HRA DECIMAL(5, 4) = 0.04; -- HRA percentage
DECLARE @LTA_Pct DECIMAL(5, 4) = 0.05; -- Leave Travel Allowance as percentage
DECLARE @MedReimbursement_Pct DECIMAL(5, 4) = 0.02; -- Medical Reimbursement as percentage
DECLARE @Conveyance_Pct DECIMAL(5, 4) = 0.03; -- Conveyance as percentage
DECLARE @SpecialAllowance_Pct DECIMAL(5, 4) = 0.05; -- Special Allowance as percentage
DECLARE @CEA_Pct DECIMAL(5, 4) = 0.05; -- Children Education Allowance as percentage
DECLARE @PF_Pct DECIMAL(5, 4) = 0.12; -- Provident Fund percentage
DECLARE @ESI_Pct DECIMAL(5, 4) = 0.035; -- Employee State Insurance percentage
DECLARE @WorkingDaysInMonth INT = 26; -- Working days in the month

-- Execute the stored procedure with the provided parameters
EXEC CalculateMonthlySalary 
    @BasicPay,
    @DA,
    @LeaveWithoutPay,
    @HRA,
    @LTA_Pct,
    @MedReimbursement_Pct,
    @Conveyance_Pct,
    @SpecialAllowance_Pct,
    @CEA_Pct,
    @PF_Pct,
    @ESI_Pct,
    @WorkingDaysInMonth;


Drop procedure CalculateMonthlySalary
