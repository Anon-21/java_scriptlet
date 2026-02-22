<html>
    <head><link rel="stylesheet" href="style.css"></head>
<body>

<div class="container">
<h2>Add Reading Entry</h2>

<%@page import="java.sql.*"%>
<%@page import="java.util.Date"%>
<%

Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;

String title = request.getParameter("title");
String author = request.getParameter("author");
String gid = request.getParameter("gid");
String status = request.getParameter("status");
String ratingStr = request.getParameter("rating");
String reviewText = request.getParameter("review_text");
String btn = request.getParameter("btn");

try
{
    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection(
    "jdbc:mysql://localhost:3306/customer",
    "root",
    "root");
%>

<!-- ================= FORM ================= -->

<form action="addEntry.jsp">
<table border="1" cellpadding="6">

<tr>
<td>Title</td>
<td><input type="text" name="title"></td>
</tr>

<tr>
<td>Author</td>
<td><input type="text" name="author"></td>
</tr>

<tr>
<td>Genre</td>
<td>
<select name="gid">
<option value="">Select</option>
<%
    ps = con.prepareStatement("select * from genre");
    rs = ps.executeQuery();

    while(rs.next())
    {
%>
<option value="<%=rs.getInt(1)%>">
<%=rs.getString(2)%>
</option>
<%
    }
%>
</select>
</td>
</tr>

<tr>
<td>Status</td>
<td>
<select name="status">
<option value="Wishlist">Wishlist</option>
<option value="Reading">Reading</option>
<option value="Finished">Finished</option>
</select>
</td>
</tr>

<tr>
<td>Rating (1-5)</td>
<td><input type="number" name="rating" min="1" max="5"></td>
</tr>

<tr>
<td>Review</td>
<td><textarea name="review_text" rows="4" cols="40"></textarea></td>
</tr>

<tr>
<td colspan="2" align="center">
<input type="submit" name="btn" value="Save Entry">
</td>
</tr>

</table>
</form>

<br>

<%
    // 🔹 INSERT LOGIC
    if(btn != null && gid != null && !gid.equals(""))
    {
        int bid = 0;

        // 1️⃣ Insert Book
        ps = con.prepareStatement(
        "insert into book(title,author,gid) values(?,?,?)",
        Statement.RETURN_GENERATED_KEYS);

        ps.setString(1,title);
        ps.setString(2,author);
        ps.setInt(3,Integer.parseInt(gid));

        ps.executeUpdate();

        ResultSet generatedKeys = ps.getGeneratedKeys();
        if(generatedKeys.next())
        {
            bid = generatedKeys.getInt(1);
        }

        // 2️⃣ Insert Reading Entry (nullable rating)
        Integer rating = null;

        if(ratingStr != null && !ratingStr.trim().equals(""))
        {
            rating = Integer.parseInt(ratingStr);
        }

        ps = con.prepareStatement(
        "insert into readingentry(bid,status,rating,review_text,date_added) values(?,?,?,?,?)",
        Statement.RETURN_GENERATED_KEYS);

        ps.setInt(1,bid);
        ps.setString(2,status);

        if(rating != null)
            ps.setInt(3,rating);
        else
            ps.setNull(3, java.sql.Types.INTEGER);

        ps.setString(4,reviewText);
        ps.setDate(5,new java.sql.Date(new java.util.Date().getTime()));

        ps.executeUpdate();

        // 🔹 Get new rid to show only latest entry
        ResultSet newKeys = ps.getGeneratedKeys();
        int newRid = 0;
        if(newKeys.next())
        {
            newRid = newKeys.getInt(1);
        }

        out.println("<b>Entry Saved Successfully! ^_^ </b><br><br>");

        // 🔹 Select ONLY the latest inserted entry
        ps = con.prepareStatement(
        "select b.title, b.author, g.gname, r.status, r.rating, r.review_text " +
        "from book b " +
        "join genre g on b.gid = g.gid " +
        "join readingentry r on b.bid = r.bid " +
        "where r.rid=?");

        ps.setInt(1,newRid);
        rs = ps.executeQuery();
%>

<table border="1" cellpadding="6">
<tr>
<th>Title</th>
<th>Author</th>
<th>Genre</th>
<th>Status</th>
<th>Rating</th>
<th>Review</th>
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
<td><%=rs.getObject(5) != null ? rs.getObject(5) : "" %></td>
<td><%=rs.getString(6)%></td>
</tr>
<%
        }
%>

</table>

<br><br>
<a href="index.jsp">Back to Home</a>

<%
    } // end if
}
catch(Exception e)
{
    out.println("Error: " + e);
}
%>

</div>
</body>
</html>
