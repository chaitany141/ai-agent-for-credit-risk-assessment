// MongoDB Initialization Script
// This script runs when the MongoDB container starts
// It sets up the database, collections, and indexes

// Switch to the loan_agent_db database
db = db.getSiblingDB('loan_agent_db');

// Create collections with validation schemas
print("Creating collections...");

// Users collection
db.createCollection("users", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["user_id", "created_at"],
      properties: {
        _id: { bsonType: "objectId" },
        user_id: { bsonType: "string", description: "Unique user identifier" },
        email: { bsonType: "string" },
        full_name: { bsonType: "string" },
        phone: { bsonType: "string" },
        kyc_verified: { bsonType: "bool", description: "KYC verification status" },
        kyc_verification_date: { bsonType: "date" },
        total_applications: { bsonType: "int", description: "Total loan applications" },
        approved_applications: { bsonType: "int" },
        rejected_applications: { bsonType: "int" },
        created_at: { bsonType: "date" },
        updated_at: { bsonType: "date" },
        last_login: { bsonType: "date" }
      }
    }
  }
});

// Loan applications collection
db.createCollection("loan_applications", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["user_id", "application_date", "status"],
      properties: {
        _id: { bsonType: "objectId" },
        user_id: { bsonType: "string" },
        application_date: { bsonType: "date" },
        loan_amount: { bsonType: "double" },
        loan_tenure: { bsonType: "int" },
        income: { bsonType: "double" },
        credit_score: { bsonType: "int" },
        employment_type: { bsonType: "string" },
        employment_length: { bsonType: "int" },
        dti: { bsonType: "double" },
        risk_score: { bsonType: "double", description: "Predicted risk score" },
        decision: { bsonType: "string", enum: ["Approved", "Rejected", "Under Review"] },
        status: { bsonType: "string" },
        reason: { bsonType: "string", description: "Reason for decision" },
        agent_explanation: { bsonType: "array" },
        created_at: { bsonType: "date" },
        updated_at: { bsonType: "date" }
      }
    }
  }
});

// Agent decisions (memory) collection
db.createCollection("agent_decisions", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["user_id", "decision_date"],
      properties: {
        _id: { bsonType: "objectId" },
        user_id: { bsonType: "string" },
        application_id: { bsonType: "string" },
        decision: { bsonType: "string" },
        confidence: { bsonType: "double" },
        reasoning: { bsonType: "string" },
        decision_date: { bsonType: "date" },
        model_version: { bsonType: "string" }
      }
    }
  }
});

// KYC documents collection
db.createCollection("kyc_documents", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["user_id", "document_type"],
      properties: {
        _id: { bsonType: "objectId" },
        user_id: { bsonType: "string" },
        document_type: { bsonType: "string", enum: ["Aadhaar", "PAN", "Passport", "DL"] },
        document_number: { bsonType: "string" },
        file_path: { bsonType: "string" },
        verification_status: { bsonType: "string", enum: ["Verified", "Pending", "Failed"] },
        uploaded_at: { bsonType: "date" },
        verified_at: { bsonType: "date" }
      }
    }
  }
});

// Credit checks collection
db.createCollection("credit_checks", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["user_id", "check_date"],
      properties: {
        _id: { bsonType: "objectId" },
        user_id: { bsonType: "string" },
        credit_score: { bsonType: "int" },
        bureau_name: { bsonType: "string" },
        check_date: { bsonType: "date" },
        debt_index: { bsonType: "double" },
        credit_history_months: { bsonType: "int" },
        total_accounts: { bsonType: "int" },
        delinquent_accounts: { bsonType: "int" },
        credit_utilization: { bsonType: "double" }
      }
    }
  }
});

// Create indexes for better query performance
print("Creating indexes...");

// Users indexes
db.users.createIndex({ "user_id": 1 });
db.users.createIndex({ "email": 1 });
db.users.createIndex({ "kyc_verified": 1 });

// Loan applications indexes
db.loan_applications.createIndex({ "user_id": 1 });
db.loan_applications.createIndex({ "application_date": -1 });
db.loan_applications.createIndex({ "decision": 1 });
db.loan_applications.createIndex({ "status": 1 });
db.loan_applications.createIndex({ "user_id": 1, "application_date": -1 });

// Agent decisions indexes
db.agent_decisions.createIndex({ "user_id": 1 });
db.agent_decisions.createIndex({ "decision_date": -1 });
db.agent_decisions.createIndex({ "application_id": 1 });

// KYC documents indexes
db.kyc_documents.createIndex({ "user_id": 1 });
db.kyc_documents.createIndex({ "document_type": 1 });
db.kyc_documents.createIndex({ "verification_status": 1 });

// Credit checks indexes
db.credit_checks.createIndex({ "user_id": 1 });
db.credit_checks.createIndex({ "check_date": -1 });

print("MongoDB initialization complete! Database: loan_agent_db");
print("Collections created: users, loan_applications, agent_decisions, kyc_documents, credit_checks");
print("Indexes created for all collections");
