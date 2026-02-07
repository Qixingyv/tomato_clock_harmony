export class DateUtils {

  public formatDate(date: Date): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0'); // 补零
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`; // 输出：2026-02-03
  }
}

export default new DateUtils();