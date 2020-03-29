package org.eustrosoft.contractpkg.pageInners;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.jsp.JspWriter;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

abstract class HtmlTags {

    private JspWriter out;

    public HtmlTags(){

    }

    public HtmlTags(JspWriter writer){

    }

    private void endForm() throws Exception { out.println("</form>"); }

    private void printProductsTableUpsideString(String... outputString) throws Exception {
        beginTRow();
        for (int i = -1; i < outputString.length; i++) {
            if (i == -1) printCell("Опции");
            else printCell(outputString[i]);
        }
        endTRow();
    }

    private void beginTCell() throws Exception { out.println("<td>"); }

    private void endTCell() throws Exception { out.println("</td>"); }

    private void beginTRow() throws Exception { out.println("<tr>"); }

    private void endTRow() throws Exception { out.println("</tr>"); }

    private void beginT() throws Exception { out.print("<table>"); }

    private void endT() throws Exception { out.println("</table>"); }

    private void printCell(Object tElement) throws IOException, Exception {
        beginTCell();
        out.println(obj2str(tElement));
        endTCell();
    }

    private void printCell(Object tElement, int colspan) throws IOException, Exception {
        out.println("<td colspan='"+colspan+"'>");
        out.println(obj2str(tElement));
        endTCell();
    }

    private void printTRow(Object[] data) throws Exception {
        beginTRow();
        for (int i = 0; i < data.length; i++) {
            printCell(data[i]);
        }
        endTRow();
    }

    private boolean checkShellInjection(String parameter){ return parameter.contains(".."); }

    public static String getCurrentDate4ZDATE() throws Exception {
        return (new SimpleDateFormat("y-MM-dd HH:mm:ss").format(new Date()));
    }

    public static String getRequestUser4ZUID(HttpServletRequest request) throws Exception{
        return (request.getRemoteUser() + "@" + request.getRemoteAddr());
    }

    private String obj2str(Object obj) {
        if(obj == null)
            obj = "";
        return obj.toString();
    }

    public void println() throws Exception { out.println("<br/>"); }

    public void printerr(String msg) throws Exception { out.print("<b>" + msg + "</b>"); }

    public void printerrln(String msg) throws Exception { printerr(msg);  println(); }
}
