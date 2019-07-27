import java.io.*;
import java.net.*;
import java.util.Scanner;
import java.lang.Thread;
class Main{
    public static void main(String[] args){
        try{
            String host = args[0];
            int port = Integer.parseInt(args[1]);
            Socket s = new Socket(host,port);
            BufferedReader in = new BufferedReader(new InputStreamReader( s.getInputStream()));
            PrintWriter out = new PrintWriter(s.getOutputStream());
            new Thread(() -> {
                while(true){
                    String str = System.console().readLine();
                    //System.out.println(str);
                    out.println(str);
                    out.flush();
                }
            }).start();
            new Thread(() -> {
                try{
                    while(true){
                        String str = in.readLine();
                        System.out.println(str);
                    }
                }catch(Exception e){}
            }).start();
        }catch(Exception e){e.printStackTrace();}
    }
}