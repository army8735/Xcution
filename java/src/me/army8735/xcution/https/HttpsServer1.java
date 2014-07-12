package me.army8735.xcution.https;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.Socket;
import java.security.KeyStore;
import java.util.Random;

import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLServerSocket;
import javax.net.ssl.SSLServerSocketFactory;
import javax.net.ssl.SSLSocket;

public class HttpsServer1 {
	/**
	 * ssl服务的端口号
	 */
	private static int port = 50003;
	private static SSLServerSocket server;

	/**
	 * as服务地址
	 */
	public static String asHost;
	/**
	 * as服务端口号
	 */
	public static int asPort;

	public static void initSSLServerSocket(String path) {
		try {
			/** 要使用的证书 **/
			if (path == null) {
				path = "";
			}
			String cert = path + "xcution.keystore";
			/** 要使用的证书密码 **/
			char certPass[] = "123456".toCharArray();
			/** 证书别称用的主要密码 **/
			char certAliaMainPass[] = "123456".toCharArray();
			/** 创建JKS密钥 **/
			KeyStore keyStore = KeyStore.getInstance("JKS");
			keyStore.load(new FileInputStream(cert), certPass);
			/** 创建管理JKS密钥库的X.509密钥管理**/
			KeyManagerFactory keyManagerFactory = KeyManagerFactory
					.getInstance("SunX509");
			keyManagerFactory.init(keyStore, certAliaMainPass);
			SSLContext sslContext = SSLContext.getInstance("TLSV1");
			/** 想使用SSL时，更改成如注释部分 **/
			// SSLContext sslContext = SSLContext.getInstance("SSLV3");
			sslContext.init(keyManagerFactory.getKeyManagers(), null, null);
			SSLServerSocketFactory sslServerSocketFactory = sslContext
					.getServerSocketFactory();
			server = (SSLServerSocket) sslServerSocketFactory
					.createServerSocket(port);
		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	public static void main(String args[]) {
		// 默认值
		asHost = "www.baidu.com";
		asPort = 80;
		port = 50003;
		// 存放证书的路径
		String path = "d:\\keys\\";

		try {
			// 从参数中获取数据
			String asHostStr = args[0];
			String asPortStr = args[1];
			String localPort = args[2];
			path = args[3];

			// 赋值
			if (asHostStr != null) {
				asHost = asHostStr;
			}
			if (asPortStr != null) {
				asPort = Integer.parseInt(asPortStr);
			}
			if (localPort != null) {
				port = Integer.parseInt(localPort);
			}
		} catch (Exception e1) {
			e1.printStackTrace();
		}

		// 如果端口被占用，那么生成另外随机的端口号
		while (isPortBind(port)) {
			port = new Random().nextInt(20000) + 20000;
		}

		try {
			// 启动服务器
			initSSLServerSocket(path);
			System.out.println("服务器在端口 [" + port + "] 等待连接...");
			while (true) {
				// 接受请求
				SSLSocket socket = (SSLSocket) server.accept();
				new HttpsServer1.CreateThread(socket);
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private static boolean isPortBind(int port) {
		try {
			Socket s = new Socket();
			s.bind(new InetSocketAddress(InetAddress.getLocalHost()
					.getHostAddress(), port));
			s.close();
			return false;
		} catch (Exception e) {
			return true;
		}
	}

	/**
	 * 读取和处理数据的线程
	 * 
	 * @author Administrator
	 *
	 */
	static class CreateThread extends Thread {
		private BufferedReader in;
		private PrintWriter out;
		private Socket s;

		public CreateThread(Socket socket) {
			try {
				s = socket;
				in = new BufferedReader(new InputStreamReader(
						s.getInputStream(), "UTF-8"));
				out = new PrintWriter(s.getOutputStream(), true);

				// 开启线程，处理数据
				start();
			} catch (Exception e) {
				e.printStackTrace();
			}

		}

		public void run() {
			System.out.println("start run");

			StringBuilder sb = new StringBuilder();

			// 请求的相对路径
			String url = null;

			try {
				// 读数据
				while (true) {
					String msg = in.readLine();
					if (msg == null || msg.length() == 0) {
						// TODO 结束判断可能不正确
						System.out.println("接受结束");
						break;
					}

					// 从http头中提取请求的url
					if (msg.startsWith("GET")) {
						url = msg.split(" ")[1];
					}

					sb.append(msg).append("\n");
					System.out.println("接收消息： " + msg);
				}

			} catch (Exception e) {
				e.printStackTrace();
			}

			// 将数据转发到as对应的http服务器
			String host = HttpsServer1.asHost;
			HttpClient client = new HttpClient(host, HttpsServer1.asPort);

			System.out.println("请求的相对路径" + url);
			// 发出http的get请求，暂时只支持httpget
			String result = client.httpGet(host, url);

			try {
				// 写数据回客户端
				out.write(result);
				out.flush();
				s.close();
			} catch (IOException e) {
				e.printStackTrace();
			}

			System.out.println("end run");
		}
	}
}
