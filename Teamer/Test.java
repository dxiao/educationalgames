import org.junit.runner.*;
import org.junit.*;

public class Test {

  @Test
  public void testAlwaysPasses() {
  }

  @Test
  public void testStuff() {
    String[] val = {0}.mostLikelyCouple(new String[] {"a b", "b c", "c a", "a d", "b d"});
    Assert.assertTrue(("a".equals(val[0]) && "b".equals(val[1])) && ("a".equals(val[1]) && "b".equals(val[0])));
  }
  
  public static void main (String[] args) {
    JUnitCore junit = new JUnitCore();
    Result result = junit.run(this.getClass());
  }
}
