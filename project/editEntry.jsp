<html>
    <head><link rel="stylesheet" href="style.css"></head>
<body>

<div class="container">
<h2>Edit Reading Entry</h2>

<%@page import="java.sql.*"%>
<%

Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;

String rid = request.getParameter("rid");
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

    // 🔹 UPDATE LOGIC
    if(btn != null)
    {
        Integer rating = null;
if(ratingStr != null && !ratingStr.trim().equals(""))
{
    rating = Integer.parseInt(ratingStr);
}


        // 1️⃣ Update Book
        ps = con.prepareStatement(
        "update book b join readingentry r on b.bid=r.bid " +
        "set b.title=?, b.author=?, b.gid=? where r.rid=?");

        ps.setString(1,title);
        ps.setString(2,author);
        ps.setInt(3,Integer.parseInt(gid));
        ps.setInt(4,Integer.parseInt(rid));
        ps.executeUpdate();

        // 2️⃣ Update Reading Entry
        ps = con.prepareStatement(
        "update readingentry set status=?, rating=?, review_text=? where rid=?");

        ps.setString(1,status);
        
        if(rating != null)
    ps.setInt(2, rating);
else
    ps.setNull(2, java.sql.Types.INTEGER);

        ps.setString(3,reviewText);
        ps.setInt(4,Integer.parseInt(rid));
        ps.executeUpdate();

        out.println("<b>Entry Updated Successfully</b><br><br>");
    }

    // 🔹 LOAD EXISTING DATA
    ps = con.prepareStatement(
    "select b.title, b.author, b.gid, r.status, r.rating, r.review_text " +
    "from book b join readingentry r on b.bid=r.bid " +
    "where r.rid=?");

    ps.setInt(1,Integer.parseInt(rid));
    rs = ps.executeQuery();
    rs.next();
%>

<form action="editEntry.jsp">
<input type="hidden" name="rid" value="<%=rid%>">

<table border="1" cellpadding="6">

<tr>
<td>Title</td>
<td><input type="text" name="title" value="<%=rs.getString(1)%>"></td>
</tr>

<tr>
<td>Author</td>
<td><input type="text" name="author" value="<%=rs.getString(2)%>"></td>
</tr>

<tr>
<td>Genre</td>
<td>
<select name="gid">
<%
    PreparedStatement ps2 = con.prepareStatement("select * from genre");
    ResultSet rs2 = ps2.executeQuery();
    while(rs2.next())
    {
        int currentGid = rs.getInt(3);
%>
<option value="<%=rs2.getInt(1)%>"
<%=rs2.getInt(1)==currentGid?"selected":""%>>
<%=rs2.getString(2)%>
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
<option value="Wishlist" <%=rs.getString(4).equals("Wishlist")?"selected":""%>>Wishlist</option>
<option value="Reading" <%=rs.getString(4).equals("Reading")?"selected":""%>>Reading</option>
<option value="Finished" <%=rs.getString(4).equals("Finished")?"selected":""%>>Finished</option>
</select>
</td>
</tr>

<tr>
<td>Rating</td>
<td><input type="number" name="rating" value="<%=rs.getInt(5)%>" min="1" max="5"></td>
</tr>

<tr>
<td>Review</td>
<td>
<textarea name="review_text" rows="4" cols="40"><%=rs.getString(6)%></textarea>
</td>
</tr>

<tr>
<td colspan="2" align="center">
<input type="submit" name="btn" value="Update Entry">
</td>
</tr>

</table>
</form>

<br><br>
<a href="viewLibrary.jsp">Back to Library</a>

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
