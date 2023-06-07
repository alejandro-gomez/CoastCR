# CoastCR 1.2.0

* This version incorporates a change in the Date format. Currently, the user can select more than one shoreline for each day. For this, the user should be introduced to the table with the dates and associated uncertainty in a column named "Day" in format (YYYYY-mm-dd). If the information about the acquisition hour is available, the user should introduce a column called "Hour" in format (HH:MM:SS). Now the column names should be "Day", "Hour" and "Uncertainty". If the data does not include the hour information, remove the column to avoid possible errors.

# CoastCR 1.1.0

* The stats summary are saving as csv file and include quantiles information.

# CoastCR 1.0.0

* Original version. Results summary save as png format file.
