// lib/features/loan_request/presentation/providers/loan_request_state.dart

/// States for the loan request form
sealed class LoanRequestFormState {
  const LoanRequestFormState();
}

class LoanRequestFormInitial extends LoanRequestFormState {
  const LoanRequestFormInitial();
}

class LoanRequestFormSubmitting extends LoanRequestFormState {
  const LoanRequestFormSubmitting();
}

class LoanRequestFormSuccess extends LoanRequestFormState {
  final Map<String, dynamic> responseData;
  const LoanRequestFormSuccess(this.responseData);
}

class LoanRequestFormError extends LoanRequestFormState {
  final String message;
  const LoanRequestFormError(this.message);
}
