package me.army8735.xcution.https;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.Socket;
import java.net.SocketTimeoutException;
import java.net.UnknownHostException;

/**
 * socket实现的一个简单http客户端
 * 
 * @author Administrator
 *
 */
public class HttpClient {

	private Socket socket;

	public HttpClient(String addr, int port) {
		try {
			socket = new Socket(addr, port);
		} catch (UnknownHostException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/**
	 * 发送GET请求
	 * 
	 * @param host
	 * @param url
	 */
	private void sendGetRequest(String host, String url) {
		try {
			OutputStream out = socket.getOutputStream();
			StringBuilder sb = new StringBuilder();
			sb.append("GET " + url + " HTTP/1.1\r\n");
			sb.append("Host: " + host + "\r\n");
			sb.append("Connection:keep-alive\r\n");
			sb.append("\r\n");
			out.write(sb.toString().getBytes("UTF-8"));
			out.flush();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/**
	 * 读取响应
	 * 
	 * @return
	 */
	private String readResponse() {
		BufferedReader in = null;
		try {
			socket.setSoTimeout(200);
			in = new BufferedReader(new InputStreamReader(
					socket.getInputStream(), "UTF-8"));
		} catch (IOException e1) {
			e1.printStackTrace();
			return null;
		}

		StringBuilder sb = new StringBuilder();

		try {
			while (true) {
				String str = in.readLine();
				if (str == null) {
					break;
				}

				sb.append(str).append("\r\n");
			}

			socket.close();
		} catch (SocketTimeoutException e) {
			System.out.println(e.getMessage());
		} catch (Exception e) {
			e.printStackTrace();
		}

		return sb.toString();
	}

	/**
	 * 发出一个http的get请求
	 * 
	 * @param host
	 * @param url
	 * @return
	 */
	public String httpGet(String host, String url) {
		this.sendGetRequest(host, url);
		return this.readResponse();
	}
}
