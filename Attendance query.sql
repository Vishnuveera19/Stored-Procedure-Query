DECLARE @StartDate DATE = '2015-5-13' -- Start date of your 10-year period
DECLARE @EndDate DATE = DATEADD(YEAR, 10, @StartDate) -- End date of your 10-year period

DECLARE @CurrentDate DATE = @StartDate

WHILE @CurrentDate <= @EndDate
BEGIN
    -- Check if the current date is not a Sunday and not a public holiday
    IF DATEPART(dw, @CurrentDate) != 1 -- Not a Sunday
    BEGIN
        -- Check if the current date is not a random leave day
        IF RAND(CHECKSUM(NEWID())) < 0.1 -- Adjust the threshold as needed for the probability of leave days (here, approximately 10%)
        BEGIN
            -- Mark as leave
            INSERT INTO attendance VALUES (2, 4, 5, 'Absent', @CurrentDate, @CurrentDate)
            PRINT 'Marking ' + CONVERT(VARCHAR, @CurrentDate) + ' as leave (random)'
        END
        ELSE
        BEGIN
            -- Perform your bulk operation here for the current date
            -- For example: 
            INSERT INTO attendance VALUES (2, 4, 5, 'Present', @CurrentDate, @CurrentDate)
            PRINT 'Performing operation for ' + CONVERT(VARCHAR, @CurrentDate)
        END
    END
    ELSE -- Sunday
    BEGIN
        -- Mark as leave
        INSERT INTO attendance VALUES (2, 4, 5, 'Sunday', @CurrentDate, @CurrentDate)
        PRINT 'Marking ' + CONVERT(VARCHAR, @CurrentDate) + ' as leave (Sunday)'
    END

    -- Move to the next day
    SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate)
END


Select * from attendance

Delete from attendance where pn_employeeId = 5