# New Posts 
New Posts is a Ruby script that parses a Wordpress RSS feed and generates a small snippet of HTML code. This is perfect for sticking in a static HTML page that you want your latest  stories to appear on. The script can be set up so the feed URL is hard coded in the script or it can take the URL feed on the command line. If you want to display more then the default  three top stories you can pass the number you want on the command line.

### Running via SSI in your HTML  
Have this run on your static HTML homepage:

<!--#exec cmd="/home/apache/bin/new_posts.rb" -->

### On the command line

new_posts.rb http://www.spauldinghill.org/blog/feed/ 4

### Issues?
Feel free to send me pull requests or email me :)
