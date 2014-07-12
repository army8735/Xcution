package me.army8735.xcution.https;

import java.net.*;  
import javax.net.ssl.*;  
import java.io.*;  
import java.security.*;  

public class HttpsServer {
    private SSLServerSocket server;
    private int 端口号;
    
    public HttpsServer(int 端口号) {
    	this.端口号 = 端口号;
    }
    public HttpsServer() {
    	this.端口号 = 8735;
    }
    public void 运行() {
    	File 当前文件夹 = new File("");
    	String 证书名 = "../src/ca.crt";
    	File 证书 = new File(证书名);
    	char 密码[] = "8735".toCharArray();
    	for(int i = 0; i < Security.getProviders().length; i++) {
    		System.out.println(Security.getProviders()[i].getName());
    	}
    	try {
    		System.out.println(证书.getCanonicalPath());
    		KeyStore keyStore = KeyStore.getInstance("JKS");
    		keyStore.load(new FileInputStream(证书), 密码);
    	} catch(IOException e) {
            e.printStackTrace();
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
    public static void main(String[] args) {
//    	HttpsServer 服务器 = new HttpsServer(Integer.parseInt(args[0]));
    	HttpsServer 服务器 = new HttpsServer();
    	服务器.运行();
    }
}
