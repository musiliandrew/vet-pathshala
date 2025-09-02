# Farmer Mode Firestore Collections

This document outlines the required Firestore collections for the farmer mode functionality in the Vet-Pathshala application.

## 1. milk_records

Stores daily milk production data for individual animals.

```json
{
  "userId": "string",
  "animalId": "string", 
  "animalName": "string",
  "date": "timestamp",
  "morningMilk": "number",
  "eveningMilk": "number",
  "totalMilk": "number",
  "quality": "string",
  "notes": "string",
  "createdAt": "timestamp"
}
```

**Usage**: Daily milk logging, production tracking, performance analytics

## 2. financial_transactions

Records all farm financial activities including income, expenses, and investments.

```json
{
  "userId": "string",
  "entryType": "string", // Income, Expense, Investment
  "category": "string",
  "amount": "number",
  "date": "timestamp",
  "paymentMethod": "string", // UPI, Cash, Bank
  "description": "string",
  "source": "string", // For income
  "vendor": "string", // For expenses
  "items": "string",
  "quantity": "number",
  "rate": "number",
  "purpose": "string",
  "receiptUrl": "string",
  "isRecurring": "boolean",
  "recurringFrequency": "string",
  "createdAt": "timestamp"
}
```

**Usage**: Financial tracking, profit/loss analysis, expense management, recurring transactions

## 3. calving_records

Tracks calving events, calf details, and birthing process information.

```json
{
  "userId": "string",
  "animalId": "string",
  "animalName": "string",
  "entryType": "string", // Normal Calving, Assisted, Loss Record
  "calvingDate": "timestamp",
  "calvingTime": "string",
  "calfSex": "string",
  "calfId": "string",
  "birthWeight": "number",
  "calvingDuration": "number", // minutes
  "dystociaScore": "number", // 0-5
  "assistance": "string",
  "complications": "string",
  "colostrumAmount": "number",
  "colostrumTime": "number", // hours
  "colostrumQuality": "string",
  "colostrumBrix": "number",
  "notes": "string",
  "createdAt": "timestamp"
}
```

**Usage**: Calving management, dystocia risk assessment, calf performance tracking

## 4. pregnancy_records

Manages pregnancy tracking, veterinary checkups, and breeding outcomes.

```json
{
  "userId": "string",
  "animalId": "string",
  "animalName": "string",
  "entryType": "string", // New Pregnancy, Checkup, PD Test
  "pregnancyDate": "timestamp",
  "sireId": "string",
  "expectedCalvingDate": "timestamp",
  "gestationDay": "number",
  "vetCheckups": "array",
  "riskFactors": "array",
  "pdTestResult": "string",
  "ultrasoundNotes": "string",
  "isActive": "boolean",
  "createdAt": "timestamp"
}
```

**Usage**: Pregnancy monitoring, veterinary scheduling, risk assessment

## 5. heat_ai_records

Records heat cycles and artificial insemination services.

```json
{
  "userId": "string",
  "animalId": "string",
  "animalName": "string",
  "recordType": "string", // Heat Observation, AI Service
  "date": "timestamp",
  "time": "string",
  "technicianName": "string",
  "semenId": "string", // For AI
  "strawNumber": "string",
  "batchNumber": "string",
  "aiMethod": "string",
  "heatSigns": "array", // For heat observation
  "heatDuration": "string",
  "heatIntensity": "string",
  "notes": "string",
  "createdAt": "timestamp"
}
```

**Usage**: Breeding cycle tracking, AI service management, heat detection

## 6. medication_records

Tracks ongoing medications, treatments, and deworming schedules.

```json
{
  "userId": "string",
  "animalId": "string",
  "animalName": "string",
  "medicationType": "string", // Deworming, Treatment, Vaccination
  "medicineName": "string",
  "dosage": "string",
  "frequency": "string",
  "startDate": "timestamp",
  "endDate": "timestamp",
  "nextDueDate": "timestamp",
  "progress": "number", // 0-100%
  "totalDays": "number",
  "completedDays": "number",
  "status": "string", // Active, Completed, Paused
  "veterinarian": "string",
  "notes": "string",
  "createdAt": "timestamp"
}
```

**Usage**: Active medication tracking, treatment progress, deworming schedules

## 7. health_records (Enhanced)

Comprehensive health record management for all medical activities.

```json
{
  "userId": "string",
  "animalId": "string",
  "animalName": "string",
  "recordType": "string", // Vaccination, Disease, Checkup, Surgery
  "date": "timestamp",
  "diagnosis": "string",
  "treatment": "string",
  "medications": "array",
  "veterinarian": "string",
  "cost": "number",
  "followUpDate": "timestamp",
  "status": "string",
  "attachments": "array",
  "createdAt": "timestamp"
}
```

**Usage**: Medical history, veterinary visits, disease tracking

## 8. breeding_analytics

Stores calculated breeding performance metrics and analytics.

```json
{
  "userId": "string",
  "animalId": "string",
  "animalName": "string",
  "heatCycleLength": "number",
  "lastHeatDate": "timestamp",
  "nextHeatDate": "timestamp",
  "conceptionRate": "number",
  "aiAttempts": "number",
  "successfulPregnancies": "number",
  "calvingInterval": "number",
  "dystociaHistory": "array",
  "updatedAt": "timestamp"
}
```

**Usage**: Breeding performance analysis, conception rate tracking, cycle predictions

## 9. farm_analytics

Dashboard summary data and farm-wide statistics.

```json
{
  "userId": "string",
  "date": "timestamp",
  "totalAnimals": "number",
  "milkingAnimals": "number",
  "pregnantAnimals": "number",
  "dailyMilkProduction": "number",
  "dailyIncome": "number",
  "dailyExpenses": "number",
  "activeMedications": "number",
  "upcomingTasks": "array",
  "monthlyStats": "object",
  "updatedAt": "timestamp"
}
```

**Usage**: Dashboard widgets, summary statistics, performance metrics

## 10. farm_settings

User preferences and farm configuration settings.

```json
{
  "userId": "string",
  "farmName": "string",
  "location": "string",
  "defaultCurrency": "string",
  "milkingSchedule": "object",
  "breedingSettings": "object",
  "notificationPreferences": "object",
  "backupFrequency": "string",
  "updatedAt": "timestamp"
}
```

**Usage**: App configuration, user preferences, notification settings

## Collection Relationships

- **animals** (existing) → Links to all records via `animalId`
- **users** (existing) → Links to all records via `userId`
- **milk_records** → Daily production data
- **financial_transactions** → Farm economics
- **breeding_analytics** → Calculated from `heat_ai_records`, `pregnancy_records`, `calving_records`
- **farm_analytics** → Aggregated from all other collections

## Security Rules Required

```javascript
// Allow users to access only their own farm data
match /milk_records/{document} {
  allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
}

// Apply same pattern to all farmer collections
match /{collection}/{document} {
  allow read, write: if request.auth != null && 
    request.auth.uid == resource.data.userId &&
    collection in ['financial_transactions', 'calving_records', 'pregnancy_records', 
                   'heat_ai_records', 'medication_records', 'health_records', 
                   'breeding_analytics', 'farm_analytics', 'farm_settings'];
}
```

These collections support all the farmer mode features: milk tracking, financial management, breeding records, health monitoring, and comprehensive analytics dashboards.