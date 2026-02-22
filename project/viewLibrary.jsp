<html>
    <head><link rel="stylesheet" href="style.css">

    </head>
<body>
<div class="container">
<h2>My Library</h2>

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

    String viewId = request.getParameter("view");


    // 🔹 JOIN QUERY (including rid for edit)
    ps = con.prepareStatement(
    "select b.title, b.author, g.gname, " +
    "r.status, r.rating, r.review_text, r.date_added, r.rid " +
    "from book b " +
    "join genre g on b.gid = g.gid " +
    "join readingentry r on b.bid = r.bid " +
    "order by r.date_added desc");

    rs = ps.executeQuery();

    String deleteId = request.getParameter("delete");

if(deleteId != null)
{
    ps = con.prepareStatement(
    "delete from readingentry where rid=?");

    ps.setInt(1,Integer.parseInt(deleteId));
    ps.executeUpdate();
}

%>

<table border="1" cellpadding="6">
<tr>
<th>Title</th>
<th>Author</th>
<th>Genre</th>
<th>Status</th>
<th>Rating</th>
<th>Review</th>
<th>Date Added</th>
<th>Edit</th>
<th>Delete</th>
</tr>

<%
    while(rs.next())
    {
%>
<tr>
<td><%=rs.getString(1)%></td>
<td><%=rs.getString(2)%></td>
<td><%=rs.getString(3)%></td>
<td><%=rs.getString(4)%></td>
<td><%=rs.getInt(5)%></td>
<td>
<%
String review = rs.getString(6);
int rid = rs.getInt(8);
if(review != null && review.length() > 100)
{
    out.print(review.substring(0,100) + "...");
%>
    <a href="viewLibrary.jsp?view=<%=rid%>">View</a>
<%
}
else
{
    out.print(review);
}
%>
</td>

<td><%=rs.getDate(7)%></td>
<td>
<a href="editEntry.jsp?rid=<%=rs.getInt(8)%>">Edit</a>
</td>
<td>
<a href="viewLibrary.jsp?delete=<%=rs.getInt(8)%>"
onclick="return confirm('Are you sure you want to delete this entry?');">
Delete
</a>
</td>
</tr>
<%
    }
%>

</table>

<%
if(viewId != null)
{
    ps = con.prepareStatement(
    "select review_text from readingentry where rid=?");
    ps.setInt(1,Integer.parseInt(viewId));
    rs = ps.executeQuery();

    if(rs.next())
    {
%>

<hr>
<h3>Full Review</h3>
<p><%=rs.getString(1)%></p>

<%
    }
}
%>


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
