
class DateUtil {

  static String formatDateCalendar(DateTime date) {// [dd/MM/yyyy]
    return (date.day < 10 ? "0${date.day}" : date.day.toString()) + "/" +
        (date.month < 10 ? "0${date.month}" : date.month.toString()) + "/" +
        date.year.toString();
  }

  static String formatDateMonth(DateTime date) {// [10 de jan]
    String result = "${date.day} de ";
    switch(date.month) {
      case 1:
        result += "jan";
        break;
      case 2:
        result += "fev";
        break;
      case 3:
        result += "mar";
        break;
      case 4:
        result += "abr";
        break;
      case 5:
        result += "mai";
        break;
      case 6:
        result += "jun";
        break;
      case 7:
        result += "jul";
        break;
      case 8:
        result += "ago";
        break;
      case 9:
        result += "set";
        break;
      case 10:
        result += "out";
        break;
      case 11:
        result += "nov";
        break;
      case 12:
        result += "dez";
        break;
    }
    return result;
  }

  static String formatDateMouthHour(DateTime date) {// [10 de jan às 20:05]
    return "${formatDateMonth(date)} às ${date.hour}:${date.minute}";
  }

  static String formatHourMinute(DateTime date) {// [20:05]
    return (date.hour < 10 ? "0${date.hour}:" : "${date.hour}:") +
        (date.minute < 10 ? "0${date.minute}" : "${date.minute}");
  }

}