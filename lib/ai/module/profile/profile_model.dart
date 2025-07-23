class ProfileModel {
  String? employeeId;
  String? userName;
  String? phoneNumber;
  int? onlineDuration;
  String? lastLoginTime;
  int? dailyTickets;
  int? monthlyTickets;
  int? yearlyTickets;

  ProfileModel(
      {this.employeeId,
      this.userName,
      this.phoneNumber,
      this.onlineDuration,
      this.lastLoginTime,
      this.dailyTickets,
      this.monthlyTickets,
      this.yearlyTickets});

  ProfileModel.fromJson(Map<String, dynamic> json) {
    employeeId = json['employee_id'];
    userName = json['user_name'];
    phoneNumber = json['phone_number'];
    onlineDuration = json['online_duration'];
    lastLoginTime = json['last_login_time'];
    dailyTickets = json['daily_tickets'];
    monthlyTickets = json['monthly_tickets'];
    yearlyTickets = json['yearly_tickets'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['employee_id'] = employeeId;
    data['user_name'] = userName;
    data['phone_number'] = phoneNumber;
    data['online_duration'] = onlineDuration;
    data['last_login_time'] = lastLoginTime;
    data['daily_tickets'] = dailyTickets;
    data['monthly_tickets'] = monthlyTickets;
    data['yearly_tickets'] = yearlyTickets;
    return data;
  }
}

class HistoryQuestionModel {
  String? questionContent;
  String? replyContent;
  String? questionTime;
  String? replyStatus;
  bool? isLiked;
  bool? isEdited;
  bool? isPlayed;
  String? inquiryMethod;
  String? selectedMachine;
  String? selectedModel;
  String? inquiry;

  HistoryQuestionModel(
      {this.questionContent,
      this.replyContent,
      this.questionTime,
      this.replyStatus,
      this.isLiked,
      this.isEdited,
      this.isPlayed,
      this.inquiryMethod,
      this.selectedMachine,
      this.selectedModel,
      this.inquiry});

  HistoryQuestionModel.fromJson(Map<String, dynamic> json) {
    questionContent = json['question_content'];
    replyContent = json['reply_content'];
    questionTime = json['question_time'];
    replyStatus = json['reply_status'];
    isLiked = json['is_liked'];
    isEdited = json['is_edited'];
    isPlayed = json['is_played'];
    inquiryMethod = json['inquiry_method'];
    selectedMachine = json['selected_machine'];
    selectedModel = json['selected_model'];
    inquiry = json['inquiry'];
  }
}
