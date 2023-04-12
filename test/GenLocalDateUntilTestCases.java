import java.time.LocalDate;
import java.time.Period;

/**
 * Generates a file full of test cases for LocalDate.until(). This function
 * is fiddly enough that it's worth thoroughly testing it against a totally
 * different implementation.
 *
 * To regenerate, run:
 *
 *    java GenLocalDateUntilTestCases.java > localdate_period_testcases.txt
 */
class GenLocalDateUntilTestCases {
	private GenLocalDateUntilTestCases() {}

	public static void main(String[] args) {
		LocalDate d1 = LocalDate.of(1999, 1, 1);
		final LocalDate end = LocalDate.of(2002, 1, 1);
		while (d1.isBefore(end)) {
			LocalDate d2 = d1;
			while (d2.isBefore(end)) {
				System.out.println(String.format("%s %s %s", d1, d2, Period.between(d1, d2)));
				d2 = d2.plusDays(1);
			}
			d1 = d1.plusDays(1);
		}
	}
}
