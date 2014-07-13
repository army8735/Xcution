package me.army8735.xcution.https;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.net.SocketTimeoutException;
import java.net.UnknownHostException;
import java.util.List;

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
	private void sendGetRequest(String host, String url, List<String> headers) {
		try {
			OutputStream out = socket.getOutputStream();
			StringBuilder sb = new StringBuilder();
			sb.append("GET " + url + " HTTP/1.1\r\n");
			sb.append("Host: " + host + "\r\n");
			for (String head : headers) {
				// 将原始的http头带上
				sb.append(head).append("\r\n");
			}
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
	private byte[] readResponse() {
		InputStream in = null;
		try {
			socket.setSoTimeout(1000);
			in = socket.getInputStream();
		} catch (IOException e1) {
			e1.printStackTrace();
			return null;
		}

		byte[] buffer = new byte[1024];
		ByteArrayOutputStream out = new ByteArrayOutputStream();

		try {
			try {
				while (true) {
					int b = in.read(buffer);

					if (b <= 0) {
						break;
					}
					
					out.write(buffer, 0, b);
				}
			} catch (SocketTimeoutException e) {
				System.err.println(e.getMessage());
			}

			socket.close();
		} catch (Exception e) {
			e.printStackTrace();
		}

		return out.toByteArray();
	}

	/**
	 * 发出一个http的get请求
	 * 
	 * @param host
	 * @param url
	 * @return
	 */
	public byte[] httpGet(String host, String url, List<String> headers) {
		this.sendGetRequest(host, url, headers);
		return this.readResponse();
	}
}
