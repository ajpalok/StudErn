# User Application System

This document explains how the user application system works in the StudErn platform.

## Overview

The system allows users to apply to recruitments (jobs, internships, micro-jobs, micro-internships) that meet specific criteria:

1. **Payment Verification**: The recruitment must have a completed payment with a valid transaction ID
2. **Easy Apply Method**: The recruitment must be set to use the "easy_apply" application collection method
3. **Open Status**: The recruitment must be open for applications
4. **User Profile**: The user must have a complete profile

## Models

### RecruitmentApply
- **Associations**: `belongs_to :user`, `belongs_to :recruitment`
- **Validations**:
  - Unique user per recruitment (prevents duplicate applications)
  - Recruitment must be open for applications
  - Recruitment must have completed payment with valid transaction ID
  - Recruitment must use easy_apply method
  - User must have complete profile
- **Status Enum**: `pending`, `accepted`, `rejected`, `withdrawn`

### User
- **Associations**: `has_many :recruitment_applies`, `has_many :applied_recruitments`
- **Helper Methods**:
  - `has_complete_profile?`: Checks if user account status is complete
  - `can_apply_to_recruitment?(recruitment)`: Checks if user can apply to a specific recruitment

### Recruitment
- **Helper Methods**:
  - `can_accept_applications?`: Checks if recruitment meets all criteria for accepting applications
  - `user_can_apply?(user)`: Checks if a specific user can apply to this recruitment
  - `application_deadline_passed?`: Checks if application deadline has passed

## Controllers

### UsersController
- `apply_to_recruitment`: Handles user application submission
- `withdraw_application`: Allows users to withdraw pending applications
- `applications`: Shows user's application history

## Routes

```ruby
get "/user/applications", to: "users#applications", as: :user_applications
post "/user/recruitment/:recruitment_id/apply", to: "users#apply_to_recruitment", as: :user_apply_to_recruitment
patch "/user/application/:application_id/withdraw", to: "users#withdraw_application", as: :user_withdraw_application
```

## Views

### Public Recruitment View
- Shows apply button only for recruitments that meet criteria
- Different states: "Apply Now", "Already Applied", "Cannot Apply", "Sign in to Apply"
- Handles both authenticated and unauthenticated users

### User Applications View
- Lists all user applications with status indicators
- Allows withdrawal of pending applications
- Shows application details and links to recruitment

## Application Flow

1. **User Authentication**: User must be signed in to apply
2. **Profile Completion**: User must have complete profile (account_status: "complete")
3. **Recruitment Eligibility**: Recruitment must meet all criteria:
   - `application_collection_status: "open"`
   - `application_collection_method: "easy_apply"`
   - Has completed payment with valid transaction ID
4. **Application Submission**: User submits application via POST request
5. **Validation**: System validates all requirements
6. **Application Creation**: If valid, creates RecruitmentApply record with status "pending"

## Payment Verification

The system ensures recruitments are only available for applications if:
- `bkash_payment` association exists
- `bkash_payment.trx_id` is present and not empty
- `bkash_payment.trx_status` is "Completed"

## Security Features

- **Unique Applications**: Database-level unique index prevents duplicate applications
- **Validation**: Multiple validation layers ensure data integrity
- **Authorization**: Users can only apply to eligible recruitments
- **Status Management**: Applications can be withdrawn but not deleted

## Usage Examples

### Check if user can apply
```ruby
if recruitment.user_can_apply?(current_user)
  # Show apply button
else
  # Show appropriate message
end
```

### Apply to recruitment
```ruby
@application = current_user.recruitment_applies.build(recruitment: @recruitment)
if @application.save
  # Success
else
  # Handle errors
end
```

### Get user's applications
```ruby
@applications = current_user.recruitment_applies.includes(:recruitment).order(created_at: :desc)
``` 