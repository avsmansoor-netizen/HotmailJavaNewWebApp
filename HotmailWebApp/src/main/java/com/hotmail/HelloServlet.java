package com.hotmail;

import java.io.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

public class HelloServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("text/html");
        PrintWriter out = resp.getWriter();
        out.println("<html><body>");
        out.println("<h2>Welcome to Hotmail WebApp!</h2>");
        out.println("<p>This app is running on Tomcat via Jenkins, SonarQube, and Nexus CI/CD pipeline.</p>");
        out.println("</body></html>");
    }
}
