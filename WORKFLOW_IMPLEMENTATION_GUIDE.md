# Workflow Implementation Guide - Flutter Client Portal

## 🎯 Overview

This document describes the complete workflow implementation for the Flutter client portal that connects with your Laravel backend's matter-specific workflow system.

## ✅ What Was Implemented

### **1. Models Created**

#### `lib/models/workflow_stage.dart`
- **WorkflowStage**: Represents individual workflow stages
  - Properties: id, name, stageName, isActive, isCurrentStage, timestamps
  - Methods: statusText getter
  
- **ActiveStageInfo**: Represents the current active stage for a matter
  - Properties: id, name, stageName, clientMatterNo, matterStatus, stageUpdatedAt
  
- **WorkflowStagesResponse**: Complete workflow response wrapper
  - Properties: workflowStages list, totalStages, activeStage, hasActiveStage, clientId, clientMatterId
  - Computed properties: currentStageIndex, progressPercentage, completedStages, remainingStages

#### `lib/models/workflow_checklist.dart`
- **WorkflowChecklist**: Represents documents required for workflow stages
  - Properties: id, checklistName, documentType, description, type, typeName, isMandatory, dueDate
  - Computed properties: hasDueDate, dueDateParsed, isOverdue, priorityLabel
  
- **ApplicationInfo**: Information about the application linked to a matter
  - Properties: applicationId, clientMatterId, clientId, currentStage, status
  
- **WorkflowChecklistResponse**: Complete checklist response wrapper
  - Properties: applicationInfo, allowedChecklists, totalAllowedChecklists, mandatoryChecklists
  - Computed properties: mandatoryChecklistsOnly, optionalChecklists, overdueChecklists

---

### **2. API Integration**

#### `lib/config/api_config.dart` - Added Endpoints
```dart
// Workflow endpoints
static const String workflowStagesEndpoint = '/workflow/stages';
static const String workflowStageDetailsEndpoint = '/workflow/stages';
static const String workflowAllowedChecklistEndpoint = '/workflow/allowed-checklist';
static const String workflowUploadChecklistEndpoint = '/workflow/upload-allowed-checklist';
```

#### `lib/services/api_service.dart` - Added Methods
```dart
// Get workflow stages with optional matter filter
static Future<Map<String, dynamic>> getWorkflowStages({int? clientMatterId})

// Get details of a specific workflow stage
static Future<Map<String, dynamic>> getWorkflowStageDetails(int stageId)

// Get allowed checklist for a matter
static Future<Map<String, dynamic>> getWorkflowAllowedChecklist({required int clientMatterId})

// Upload document for workflow checklist
static Future<Map<String, dynamic>> uploadWorkflowChecklistDocument({
  required String filePath,
  required int allowedChecklistId,
  required int clientMatterId,
})
```

---

### **3. UI Components**

#### `lib/widgets/workflow/workflow_progress_widget.dart`
Complete workflow visualization widget showing:
- Progress summary card with completed/current/remaining stats
- Animated progress bar
- Vertical timeline of all stages with visual indicators
- Tap-to-view stage details functionality

**Features:**
- Color-coded stages (green=completed, blue=current, gray=upcoming)
- Icons indicating status (check_circle, radio_button_checked, radio_button_unchecked)
- Visual connection lines between stages
- Highlighted current stage with border and shadow effects

#### `lib/widgets/workflow/workflow_timeline_widget.dart`
Flexible timeline widget with two display modes:
- **Compact Mode**: Mini progress card for dashboards
- **Full Mode**: Complete stage list with details

**Features:**
- Progress percentage display
- Stat chips showing completed/remaining/total
- Current stage highlighting
- Responsive design

---

### **4. Screens**

#### `lib/screens/workflow/workflow_screen.dart`
Main workflow management screen with two tabs:

**Tab 1: Stages**
- Shows complete workflow progress
- Displays all stages in vertical timeline
- Visual progress indicators
- Tap stages to view details
- Pull-to-refresh support

**Tab 2: Documents**
- Lists all required documents for current workflow
- Shows mandatory vs optional documents
- Due date indicators with overdue warnings
- One-click document upload functionality
- Upload progress tracking
- Summary card showing total/required/optional counts

**Key Features:**
- Matter name in app bar
- Real-time upload status
- File picker integration (PDF, DOC, DOCX, JPG, JPEG, PNG)
- Error handling with retry options
- Loading states for better UX

---

### **5. Navigation Integration**

#### Dashboard Integration
Updated `QuickActionsCard` to include "View Workflow" button
- Purple-themed action button
- Navigates to workflow screen with matter context
- Fetches matter name automatically

#### Route Configuration (`lib/main.dart`)
```dart
onGenerateRoute: (settings) {
  if (settings.name == '/workflow') {
    final args = settings.arguments as Map<String, dynamic>;
    return MaterialPageRoute(
      builder: (context) => WorkflowScreen(
        clientMatterId: args['clientMatterId'],
        matterName: args['matterName'],
      ),
    );
  }
  return null;
}
```

---

## 🔌 Backend API Integration

### **Endpoints Used**

1. **GET /api/workflow/stages?client_matter_id={id}**
   - Returns all workflow stages
   - Marks current active stage
   - Provides progress data

2. **GET /api/workflow/stages/{stage_id}**
   - Returns details of specific stage
   - Shows matters in that stage

3. **GET /api/workflow/allowed-checklist?client_matter_id={id}**
   - Returns documents client can upload
   - Filters by application linked to matter
   - Shows mandatory vs optional documents

4. **POST /api/workflow/upload-allowed-checklist**
   - Uploads document to AWS S3
   - Links to specific checklist item
   - Creates activity log
   - Body: `file` (multipart), `client_matter_id`, `allowed_checklist_id`

---

## 📊 Data Flow

```
1. User logs in → Selects Matter
2. Dashboard loads with matter_id
3. User clicks "View Workflow" button
4. WorkflowScreen loads:
   a. Fetches workflow stages (GET /workflow/stages)
   b. Fetches allowed checklists (GET /workflow/allowed-checklist)
5. User views progress and stages
6. User uploads required documents
7. Document uploaded to S3
8. Activity log created in Laravel
9. Workflow screen refreshes to show updated data
```

---

## 🎨 UI/UX Features

### Visual Design
- **Color Coding:**
  - 🟢 Green: Completed stages
  - 🔵 Blue: Current stage
  - ⚪ Gray: Upcoming stages

- **Icons:**
  - ✅ Check circle: Completed
  - 🔘 Radio checked: Current
  - ⚪ Radio unchecked: Upcoming

### User Experience
- Pull-to-refresh on all screens
- Real-time upload progress
- Clear error messages with retry options
- Loading states during API calls
- Toast notifications for success/failure
- File type validation
- File size limits (10MB max)

### Accessibility
- Clear labels and descriptions
- High contrast colors
- Touch-friendly tap targets
- Error messages with actionable steps

---

## 🔄 Integration with Existing Backend

### Database Tables Used
- `client_matters`: Links client to matter and workflow stage
- `workflow_stages`: Defines all workflow stages
- `applications`: Links matter to application workflow
- `application_document_lists`: Defines required documents (checklist)
- `application_documents`: Stores uploaded documents
- `admins`: Client authentication (role=7, cp_status=1)

### Matter-Specific Workflow Logic
The workflow is **matter-specific** because:
1. Each `client_matter` has its own `workflow_stage_id`
2. Different matters can be at different stages simultaneously
3. Documents are linked to specific matters via `client_matter_id`
4. Workflow progress is calculated per matter

---

## 🚀 How to Use in the App

### For Users:
1. **Login** to the app
2. **Select a matter** from the matters list
3. **View Dashboard** for selected matter
4. Click **"View Workflow"** quick action button
5. See **two tabs:**
   - **Stages Tab**: Visual timeline showing progress
   - **Documents Tab**: Upload required documents

### For Developers:
Navigate programmatically:
```dart
Navigator.pushNamed(
  context,
  '/workflow',
  arguments: {
    'clientMatterId': 123,
    'matterName': 'Skilled Migration (SM_1)',
  },
);
```

---

## 📝 Key Features

### ✅ Completed Features
- [x] Workflow stages visualization
- [x] Progress tracking with percentage
- [x] Current stage highlighting
- [x] Document checklist display
- [x] Mandatory vs optional document indication
- [x] Document upload functionality
- [x] Due date tracking with overdue warnings
- [x] Pull-to-refresh support
- [x] Error handling with retry
- [x] Loading states
- [x] Integration with dashboard
- [x] Matter-specific workflows
- [x] AWS S3 upload integration
- [x] Activity logging on backend

### 🎯 Backend Features (Already Working)
- [x] Publish/unpublish documents (admin only)
- [x] Document status tracking (status=1 for published to client)
- [x] Client portal toggle (cp_status)
- [x] Password generation on activation
- [x] Email notifications
- [x] Workflow stage progression
- [x] Application activity logs

---

## 🔧 Technical Details

### File Upload Process
1. User clicks "Upload Document" on checklist item
2. File picker opens (filters: PDF, DOC, DOCX, JPG, JPEG, PNG)
3. User selects file
4. Upload progress shown
5. File sent via multipart/form-data:
   - `file`: The document file
   - `client_matter_id`: Matter ID
   - `allowed_checklist_id`: Checklist item ID
6. Laravel controller:
   - Validates file name (only alphanumeric, dashes, underscores, dots, dollar signs)
   - Renames file: `{firstname}_{checklistname}_{timestamp}.{ext}`
   - Uploads to S3: `application_documents/{client_id}/{filename}`
   - Saves record to `application_documents` table
   - Returns file URL and metadata
7. Success message shown to user
8. Checklist refreshes automatically

### State Management
- Uses `setState()` for local state
- Separate loading states for workflow and checklist
- Upload states tracked per checklist item
- Error states with retry capability

### Performance Optimizations
- Lazy loading of stage details
- Pagination support ready (backend provides it)
- Efficient list rendering
- Cached API responses via Flutter's HTTP client

---

## 🐛 Error Handling

### Network Errors
- Connection timeouts (30 seconds)
- No internet connection
- Server unavailable (500, 502, 503)

### Business Logic Errors
- Invalid matter ID (404)
- Unauthorized access (401, 403)
- Validation errors (422)
- File too large
- Invalid file type

### User Feedback
- Error dialogs with clear messages
- Retry buttons
- Toast notifications
- Loading indicators

---

## 📱 Testing Checklist

### Workflow Stages Tab
- [ ] Workflow loads for selected matter
- [ ] Progress bar shows correct percentage
- [ ] Current stage is highlighted
- [ ] Completed stages show green checkmarks
- [ ] Upcoming stages show gray circles
- [ ] Tapping stage shows details
- [ ] Pull-to-refresh works

### Documents Tab
- [ ] Checklists load correctly
- [ ] Mandatory documents marked as "Required"
- [ ] Optional documents shown
- [ ] Due dates displayed
- [ ] Overdue items highlighted in red
- [ ] Upload button opens file picker
- [ ] Only allowed file types can be selected
- [ ] Upload progress shown
- [ ] Success message after upload
- [ ] Checklist refreshes after upload
- [ ] Large files rejected with error message

### Dashboard Integration
- [ ] "View Workflow" button appears
- [ ] Clicking button navigates to workflow screen
- [ ] Matter name passed correctly
- [ ] Back navigation works

### Error Scenarios
- [ ] No internet - shows error with retry
- [ ] Invalid matter ID - shows appropriate message
- [ ] No workflow stages - shows empty state
- [ ] No checklists - shows "none required" message
- [ ] Upload fails - shows error, allows retry

---

## 📚 Code Examples

### Navigate to Workflow from Anywhere
```dart
// Get matter name first
final mattersResponse = await ApiService.getMatters();
final matters = mattersResponse['data']['matters'] as List;
final matter = matters.firstWhere((m) => m['matter_id'] == selectedMatterId);

// Navigate with matter context
Navigator.pushNamed(
  context,
  '/workflow',
  arguments: {
    'clientMatterId': selectedMatterId,
    'matterName': matter['matter_name'],
  },
);
```

### Use Workflow Widget Standalone
```dart
// In any screen, show compact workflow progress
FutureBuilder<Map<String, dynamic>>(
  future: ApiService.getWorkflowStages(clientMatterId: matterId),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();
    
    final workflowResponse = WorkflowStagesResponse.fromJson(
      snapshot.data!['data']
    );
    
    return CompactWorkflowProgress(
      workflowResponse: workflowResponse,
    );
  },
)
```

---

## 🔒 Security Considerations

### Client-Side
- All API calls require authentication (Sanctum token)
- File picker restricts file types
- File size validation before upload
- Proper error messages without exposing sensitive data

### Server-Side (Your Laravel API)
- ✅ Authentication required (auth:sanctum middleware)
- ✅ Client role validation (role=7, cp_status=1)
- ✅ Client can only see their own matters
- ✅ Only allowed checklists can receive uploads (allow_client=1)
- ✅ File name sanitization
- ✅ AWS S3 secure storage
- ✅ Activity logging for audit trail

---

## 📞 API Response Examples

### Workflow Stages Response
```json
{
  "success": true,
  "data": {
    "workflow_stages": [
      {
        "id": 1,
        "name": "Document Collection",
        "stage_name": "Document Collection",
        "is_active": false,
        "is_current_stage": false,
        "created_at": "2024-01-01 00:00:00",
        "updated_at": "2024-01-01 00:00:00"
      },
      {
        "id": 2,
        "name": "Application Preparation",
        "stage_name": "Application Preparation",
        "is_active": true,
        "is_current_stage": true,
        "created_at": "2024-01-01 00:00:00",
        "updated_at": "2024-01-01 00:00:00"
      }
    ],
    "total_stages": 14,
    "active_stage": {
      "id": 2,
      "name": "Application Preparation",
      "stage_name": "Application Preparation",
      "client_matter_no": "SM_1",
      "matter_status": 1,
      "stage_updated_at": "2024-03-15 10:30:00",
      "is_active": true
    },
    "has_active_stage": true,
    "client_id": 123,
    "client_matter_id": 456
  }
}
```

### Allowed Checklist Response
```json
{
  "success": true,
  "data": {
    "application_info": {
      "application_id": 789,
      "client_matter_id": 456,
      "client_id": 123,
      "current_stage": "Application Preparation",
      "status": 0
    },
    "allowed_checklists": [
      {
        "id": 101,
        "checklist_name": "Passport Copy",
        "document_type": "Passport Copy",
        "description": "Clear color copy of all pages",
        "type": "application-preparation",
        "type_name": "Application Preparation",
        "is_mandatory": true,
        "due_date": "2024-04-01",
        "due_time": "17:00:00",
        "created_at": "2024-01-01 00:00:00",
        "updated_at": "2024-01-01 00:00:00"
      }
    ],
    "total_allowed_checklists": 5,
    "mandatory_checklists": 3,
    "client_matter_id": 456
  }
}
```

---

## 🎨 UI Screenshots Description

### Workflow Screen - Stages Tab
```
┌─────────────────────────────────┐
│ ← Workflow                      │
│   Skilled Migration (SM_1)      │
│ ─────────────────────────────── │
│ [Stages] [Documents]            │
├─────────────────────────────────┤
│ ┌───────────────────────────┐   │
│ │ Workflow Summary          │   │
│ │ ✓ Completed: 2            │   │
│ │ ⏳ Current: 1              │   │
│ │ ⏱ Remaining: 11           │   │
│ └───────────────────────────┘   │
│                                 │
│ Overall Progress         14%    │
│ ████░░░░░░░░░░░░░░░░░           │
│                                 │
│ All Stages                      │
│ ● ✓ Document Collection         │
│ │   Completed                   │
│ │                               │
│ ● ✓ Initial Consultation        │
│ │   Completed                   │
│ │                               │
│ ● ◉ Application Preparation     │
│     Current ←                   │
│ │                               │
│ ● ○ Lodgement                   │
│     Upcoming                    │
└─────────────────────────────────┘
```

### Workflow Screen - Documents Tab
```
┌─────────────────────────────────┐
│ ← Workflow                      │
│   Skilled Migration (SM_1)      │
│ ─────────────────────────────── │
│ [Stages] [Documents]            │
├─────────────────────────────────┤
│ ┌───────────────────────────┐   │
│ │ Documents Summary         │   │
│ │ Total: 5 | Required: 3    │   │
│ │ Optional: 2               │   │
│ └───────────────────────────┘   │
│                                 │
│ ℹ Current Stage:                │
│   Application Preparation       │
│                                 │
│ ┌───────────────────────────┐   │
│ │ Passport Copy   [Required]│   │
│ │ Clear color copy...       │   │
│ │ 📅 Due: 2024-04-01        │   │
│ │ [Upload Document]         │   │
│ └───────────────────────────┘   │
│                                 │
│ ┌───────────────────────────┐   │
│ │ Police Certificate        │   │
│ │ From country of residence │   │
│ │ [Upload Document]         │   │
│ └───────────────────────────┘   │
└─────────────────────────────────┘
```

---

## 🔍 Troubleshooting

### Issue: Workflow doesn't load
**Check:**
1. Is matter ID valid?
2. Is client portal status active (cp_status=1)?
3. Does client_matter exist with workflow_stage_id?
4. Is auth token valid?

**Solution:** Check network tab for API response

### Issue: Checklists are empty
**Check:**
1. Does application exist in `applications` table?
2. Are there records in `application_document_lists` with `allow_client=1`?
3. Is the matter linked to an application?

**Solution:** Admin must create application and add allowed checklists

### Issue: Upload fails
**Check:**
1. File size < 10MB?
2. File type allowed (PDF, DOC, DOCX, JPG, PNG)?
3. File name contains only valid characters?
4. AWS S3 credentials configured?

**Solution:** Check Laravel logs, verify S3 configuration

---

## 🎯 Next Steps / Future Enhancements

### Potential Additions
1. **Download uploaded documents**: View already uploaded files
2. **Document history**: See version history
3. **Comments on documents**: Leave notes for admin
4. **Push notifications**: When stage changes or documents requested
5. **Signature capture**: For document signing
6. **Batch upload**: Multiple documents at once
7. **Offline support**: Queue uploads when offline
8. **Document preview**: View PDFs in-app
9. **Stage notifications**: Alert when moved to next stage
10. **Estimated completion date**: Based on current progress

---

## 📦 Dependencies Used

```yaml
# pubspec.yaml additions needed
dependencies:
  file_picker: ^latest  # For document selection
  http: ^latest  # For API calls
  shared_preferences: ^latest  # For local storage
```

---

## ✨ Summary

The workflow implementation provides:
- ✅ **Complete matter-specific workflow visualization**
- ✅ **Document upload capability for workflow checklists**
- ✅ **Real-time progress tracking**
- ✅ **Seamless integration with existing Laravel backend**
- ✅ **User-friendly interface matching your branding**
- ✅ **Secure file handling via AWS S3**
- ✅ **Activity logging for compliance**

The app is now ready to show clients their case progress and allow them to submit required documents through the mobile portal! 🎉
