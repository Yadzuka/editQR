package org.eustrosoft.contractpkg.pageInners;

import javax.servlet.jsp.JspWriter;
import java.io.IOException;

public class EditQRHtmlTags extends HtmlTags {
    private String [] STD_REQUEST_PARAMETERS;
    private String CGI_NAME, CMD_UPDATE;
    private JspWriter out;

    public EditQRHtmlTags(String cgi_name, String cmd_update, String[] std_req_par, JspWriter writer) {
        super(writer);
        out = writer;
        STD_REQUEST_PARAMETERS = std_req_par;
        CGI_NAME = cgi_name;
        CMD_UPDATE = cmd_update;
    }

    private String getRequestParamsURL(String ... params){
        if(params == null)
            return (null);
        StringBuffer buffer = new StringBuffer();
        int i = 0;
        if(CGI_NAME.equals(params[0])) {
            buffer.append(CGI_NAME + "?");
            i++;
        }
        for( int j = 0; i < params.length; i++, j++){
            if(i != params.length - 1)
                buffer.append(STD_REQUEST_PARAMETERS[j] +"=" + params[i] + "&");
            else
                buffer.append(STD_REQUEST_PARAMETERS[j] + "=" + params[i]);
        }
        return buffer.toString();
    }

    private void printUpsideMenu(String[] menuItems, String[] menuReferences) throws IOException, Exception {
        out.println("<ul>");
        for (int i = 0; i < menuItems.length; i++) {
            out.print("<li>");
            out.println("<a href=\'" + CGI_NAME + "?" + menuReferences[i] + "\'>" + menuItems[i] + "</a>");
            out.print("</li>");
        }
        out.println("</ul>");
        println();
    }

    private void startCreateForm(String member, String range, String action) throws Exception {
        action = "save"; // !SIC строка внизу + member -> + encode_url_value(member) -> + euv(member) и так везде надо
        out.println("<form action=\"" + getRequestParamsURL(CGI_NAME,CMD_UPDATE,member,range, null,action) + "\" method=\"POST\">");
    }

    private void startUpdateForm(String member, String range, String ZRID, String action) throws Exception {
        action = "save";
        out.println("<form action=\"" + getRequestParamsURL(CGI_NAME,CMD_UPDATE,member,range,ZRID,action) + "\" method=\"POST\">");
    }
}
