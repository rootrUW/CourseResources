Set NoCount On; -- Turns off the (1 row affected) messages
Go

Use TempDb;
Go

If Exists (
  Select Name
  From Sys.Tables
  Where Name = 'SignupForMeetings'
)
  Drop Table SignupForMeetings;
Go

If Exists (
  Select Name
  From Sys.Tables
  Where Name = 'Meetings'
)
  Drop Table Meetings;
Go

-- Make dependent tables.
Create Table dbo.Meetings (
  MeetingId int Not Null,
  MeetingDateAndTime datetime,
  Constraint pkMeetings Primary Key (MeetingId)
);
Go

Insert Into dbo.Meetings (
  MeetingId,
  MeetingDateAndTime
)
Values (
  1,
  '1/1/2020 10:00:00'
);
Go

Create Table dbo.SignupForMeetings (
  SignupId int Not Null,
  SignupDateTime datetime,
  MeetingId int,
  Constraint pkSignupForMeetings Primary Key (SignupId),
  Constraint fkSignupForMeetingsMeetings Foreign Key (MeetingId) References dbo.Meetings (MeetingId)
);
Go

Insert Into dbo.SignupForMeetings (
  SignupId,
  SignupDateTime,
  MeetingId
)
Values (
  1,
  '1/1/2020 11:00:00',
  1
); -- Opps! This is One hour AFTER the meeting
Go

-- Remove that row and work on a way to Fix this issue!
Delete From dbo.SignupForMeetings
Where SignupId = 1;
Go

Select
  MeetingId,
  MeetingDateAndTime
From dbo.Meetings;

Select
  SignupId,
  SignupDateTime,
  MeetingId
From dbo.SignupForMeetings;
Go

-- Make a function that will get the meeting date and time based on a meeting ID
Create Or Alter Function dbo.fGetMeetingDateTime (
  @MeetingId int
)
Returns datetime
As
Begin
  Return (
    Select MeetingDateAndTime
    From dbo.Meetings
    Where Meetings.MeetingId = @MeetingId
  );
End;
Go

-- Test the function
Select dbo.fGetMeetingDateTime(1);

Select
  Iif(Cast('1/1/2020 07:00:00' As datetime) < dbo.fGetMeetingDateTime(1), 'TRUE', 'FALSE'),
  'Before Start';

Select
  Iif(Cast('1/1/2020 11:00:00' As datetime) < dbo.fGetMeetingDateTime(1), 'TRUE', 'FALSE'),
  'After Start';
Go

-- Now, create a constraint that checks that a signup is before the meeting time
Alter Table dbo.SignupForMeetings
Add Constraint ckSignupVsMeetingDateTime
  Check (SignupDateTime < dbo.fGetMeetingDateTime(MeetingId));
Go

-- Test the check constraint
Insert Into dbo.SignupForMeetings (
  SignupId,
  SignupDateTime,
  MeetingId
)
Values (
  1,
  '1/1/2020 9:00:00',
  1
); -- One hour BEFORE the meeting
Go

Insert Into dbo.SignupForMeetings (
  SignupId,
  SignupDateTime,
  MeetingId
)
Values (
  2,
  '1/1/2020 11:00:00',
  1
); -- One hour AFTER the meeting
Go

Select
  MeetingId,
  MeetingDateAndTime
From dbo.Meetings;

Select
  SignupId,
  SignupDateTime,
  MeetingId
From dbo.SignupForMeetings;
Go