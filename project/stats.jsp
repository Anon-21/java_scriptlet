<html>
    <head><link rel="stylesheet" href="style.css"></head>
<body>
<div class="container">
<h2>Reading Statistics</h2>

<%@page import="java.sql.*"%>
<%

Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;

try
{
    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/customer",
    "root",
    "root");

    ps = con.prepareStatement("select count(*) from book");
    rs = ps.executeQuery();
    rs.next();
    int totalBooks = rs.getInt(1);

    ps = con.prepareStatement(
    "select count(*) from readingentry where status='Finished'");
    rs = ps.executeQuery();
    rs.next();
    int finishedBooks = rs.getInt(1);
    
    ps = con.prepareStatement(
    "select avg(rating) from readingentry where status='Finished'");
    rs = ps.executeQuery();
    rs.next();
    double avgRating = rs.getDouble(1);

%>

<table border="1" cellpadding="8">
<tr><td>Total Books Added</td><td><%=totalBooks%></td></tr>
<tr><td>Books Finished</td><td><%=finishedBooks%></td></tr>
<tr><td>Average Rating (Finished)</td><td><%=String.format("%.2f",avgRating)%></td></tr>
</table>

<br><br>

<h3>Top Rated Books</h3>

<%
    ps = con.prepareStatement(
    "select b.title, r.rating " +
    "from book b join readingentry r on b.bid=r.bid " +
    "where r.status='Finished' " +
    "order by r.rating desc");
    rs = ps.executeQuery();
%>

<table border="1" cellpadding="6">
<tr>
<th>Title</th>
<th>Rating</th>
</tr>

<%
    while(rs.next())
    {
%>
<tr>
<td><%=rs.getString(1)%></td>
<td><%=rs.getInt(2)%></td>
</tr>
<%
    }
%>
</table>

<br><br>

<h3>Books Read Per Genre</h3>

<%
    ps = con.prepareStatement(
    "select g.gname, count(*) " +
    "from genre g " +
    "join book b on g.gid=b.gid " +
    "join readingentry r on r.bid=b.bid " +
    "where r.status='Finished' " +
    "group by g.gname " +
    "order by count(*) desc");

    rs = ps.executeQuery();
%>

<table border="1" cellpadding="6">
<tr>
<th>Genre</th>
<th>Total Finished</th>
</tr>

<%
    while(rs.next())
    {
%>
<tr>
<td><%=rs.getString(1)%></td>
<td><%=rs.getInt(2)%></td>
</tr>
<%
    }
%>

</table>

<br><br>
<a href="index.jsp">Back to Home</a>

<%
}
catch(Exception e)
{
    out.println("Error: " + e);
}
%>

</div>
</body>
</html>
