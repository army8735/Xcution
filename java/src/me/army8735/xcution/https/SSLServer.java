package me.army8735.xcution.https;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.ClosedChannelException;
import java.nio.channels.SelectableChannel;
import java.nio.channels.SelectionKey;
import java.nio.channels.Selector;
import java.nio.channels.ServerSocketChannel;
import java.nio.channels.SocketChannel;
import java.nio.charset.Charset;
import java.nio.charset.CharsetDecoder;
import java.nio.charset.CharsetEncoder;
import java.security.GeneralSecurityException;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.UnrecoverableKeyException;
import java.security.cert.CertificateException;
import java.util.Iterator;

import javax.net.ssl.KeyManagerFactory;
import javax.net.ssl.SSLContext;
import javax.net.ssl.SSLEngine;
import javax.net.ssl.SSLEngineResult;
import javax.net.ssl.SSLException;
import javax.net.ssl.SSLSession;
import javax.net.ssl.TrustManagerFactory;
import javax.net.ssl.SSLEngineResult.HandshakeStatus;

public class SSLServer {

	private static boolean logging = true;
	
	private boolean handshakeDone = false;
	
	private Selector selector;
	private SSLEngine sslEngine;
	private SSLContext sslContext;
	
	private ByteBuffer appOut; // clear text buffer for out
	private ByteBuffer appIn; // clear text buffer for in
	private ByteBuffer netOut; // encrypted buffer for out
	private ByteBuffer netIn; // encrypted buffer for in

	private CharsetEncoder encoder = Charset.forName("UTF8").newEncoder();
	private CharsetDecoder decoder = Charset.forName("UTF8").newDecoder();
	
	public SSLServer() {
		try
		{
			createServerSocket();
		} catch (IOException e)
		{
			System.out.println("initializing server failed");
			e.printStackTrace();
		}
		
		try
		{
			createSSLContext();
		} catch (GeneralSecurityException e)
		{
			System.out.println("initializing SSL context failed");
			e.printStackTrace();
		} catch (IOException e)
		{
			System.out.println("reading keystore or truststore file failed");
			e.printStackTrace();
		}
		
		createSSLEngines();
		createBuffers();
	}
	
	private void createBuffers()
	{
		SSLSession session = sslEngine.getSession();
		int appBufferMax = session.getApplicationBufferSize();
		int netBufferMax = session.getPacketBufferSize();
		
		appOut = ByteBuffer.wrap("This is an SSL Server".getBytes());//server only reply this sentence 
		appIn = ByteBuffer.allocate(appBufferMax + 10);//appIn is bigger than the allowed max application buffer siz
		netOut = ByteBuffer.allocateDirect(netBufferMax);//direct allocate for better performance
		netIn = ByteBuffer.allocateDirect(netBufferMax);
	}

	//the ssl context initialization
	private void createSSLContext() throws GeneralSecurityException, FileNotFoundException, IOException
	{
		KeyStore ks = KeyStore.getInstance("JKS");
		KeyStore ts = KeyStore.getInstance("JKS");

		char[] passphrase = "123456".toCharArray();

		ks.load(new FileInputStream("ssl/kserver.keystore"), passphrase);
		ts.load(new FileInputStream("ssl/tserver.keystore"), passphrase);

		KeyManagerFactory kmf = KeyManagerFactory.getInstance("SunX509");
		kmf.init(ks, passphrase);

		TrustManagerFactory tmf = TrustManagerFactory.getInstance("SunX509");
		tmf.init(ts);

		SSLContext sslCtx = SSLContext.getInstance("SSL");

		sslCtx.init(kmf.getKeyManagers(), tmf.getTrustManagers(), null);

		sslContext = sslCtx;
		
	}

	//create the server socket, bind it to port 1234, set unblock and register the "accept" only
	private void createServerSocket() throws IOException
	{
		selector = Selector.open();
		ServerSocketChannel ssc = ServerSocketChannel.open();
		ssc.socket().bind(new InetSocketAddress(1234));
		ssc.configureBlocking(false);
		ssc.register(selector, SelectionKey.OP_ACCEPT);
	}

	private void createSSLEngines() 
	{
		sslEngine = sslContext.createSSLEngine();
		sslEngine.setUseClientMode(false);//work in a server mode
		sslEngine.setNeedClientAuth(true);//need client authentication
	}
	
	public void selecting() {
		while (true)
		{
			try
			{
				selector.select();
			} catch (IOException e)
			{
				e.printStackTrace();
			}
			Iterator<SelectionKey> iter = selector.selectedKeys().iterator();
			while (iter.hasNext())
			{
				SelectionKey key = (SelectionKey) iter.next();
				iter.remove();
				try
				{
					handle(key);
				} catch (SSLException e)
				{
					// TODO Auto-generated catch block
					e.printStackTrace();
				} catch (IOException e)
				{
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		}
	}

	private void handle(SelectionKey key) throws IOException
	{
		if(key.isAcceptable()) {
			
			try
			{
				SocketChannel sc = ((ServerSocketChannel)key.channel()).accept();
				doHandShake(sc);//if it is an accept event, do the handshake in a blocking mode
			} catch (ClosedChannelException e)
			{
				// TODO Auto-generated catch block
				e.printStackTrace();
			} catch (IOException e)
			{
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		else if(key.isReadable()) {
			if (sslEngine.getHandshakeStatus() == HandshakeStatus.NOT_HANDSHAKING)
			{
				SocketChannel sc = (SocketChannel) key.channel();
				sc.read(netIn);
				netIn.flip();
				
				SSLEngineResult engineResult = sslEngine.unwrap(netIn, appIn);
				log("server unwrap: ", engineResult);
				doTask();
				//runDelegatedTasks(engineResult, sslEngine);
				netIn.compact();
				if (engineResult.getStatus() == SSLEngineResult.Status.OK)
				{
					System.out.println("text recieved");
					appIn.flip();// ready for reading
					System.out.println(decoder.decode(appIn));
					appIn.compact();
				}
				else if(engineResult.getStatus() == SSLEngineResult.Status.CLOSED) {
					doSSLClose(key);
				}

			}

		}
		else if(key.isWritable()) {
			SocketChannel sc = (SocketChannel) key.channel();
			//if(!sslEngine.isOutboundDone()) {
				//netOut.clear();
			SSLEngineResult engineResult = sslEngine.wrap(appOut, netOut);
			log("server wrap: ", engineResult);
			doTask();
			//runDelegatedTasks(engineResult, sslEngine);
			if (engineResult.getHandshakeStatus() == HandshakeStatus.NOT_HANDSHAKING)
			{
				System.out.println("text sent");
			}
			netOut.flip();
			sc.write(netOut);
			netOut.compact();
			//}
		}
		
	}

	/*public static HandshakeStatus runDelegatedTasks(SSLEngineResult engineResult, SSLEngine sslEngine)
	{
		if (engineResult.getHandshakeStatus() == HandshakeStatus.NEED_TASK)
		{
			Runnable runnable;
			while ((runnable = sslEngine.getDelegatedTask()) != null)
			{
				System.out.println("\trunning delegated task...");
				runnable.run();
			}
			HandshakeStatus hsStatus = sslEngine.getHandshakeStatus();
			if (hsStatus == HandshakeStatus.NEED_TASK)
			{
				//throw new Exception("handshake shouldn't need additional tasks");
				System.out.println("handshake shouldn't need additional tasks");
			}
			System.out.println("\tnew HandshakeStatus: " + hsStatus);
		}
		return sslEngine.getHandshakeStatus();
		
	}*/

	/*
	 * Logging code
	 */
	private static boolean resultOnce = true;

	public static void log(String str, SSLEngineResult result)
	{
		if (!logging)
		{
			return;
		}
		if (resultOnce)
		{
			resultOnce = false;
			System.out.println("The format of the SSLEngineResult is: \n"
					+ "\t\"getStatus() / getHandshakeStatus()\" +\n"
					+ "\t\"bytesConsumed() / bytesProduced()\"\n");
		}
		HandshakeStatus hsStatus = result.getHandshakeStatus();
		log(str + result.getStatus() + "/" + hsStatus + ", " + result.bytesConsumed() + "/"
				+ result.bytesProduced() + " bytes");
		if (hsStatus == HandshakeStatus.FINISHED)
		{
			log("\t...ready for application data");
		}
	}

	public static void log(String str)
	{
		if (logging)
		{
			System.out.println(str);
		}
	}
	
	
	private void doHandShake(SocketChannel sc) throws IOException
	{
		
		sslEngine.beginHandshake();//explicitly begin the handshake
		HandshakeStatus hsStatus = sslEngine.getHandshakeStatus();
		while (!handshakeDone)
		{
			switch(hsStatus){
				case FINISHED:
					//the status become FINISHED only when the ssl handshake is finished
					//but we still need to send data, so do nothing here
					break;
				case NEED_TASK:
					//do the delegate task if there is some extra work such as checking the keystore during the handshake
					hsStatus = doTask();
					break;
				case NEED_UNWRAP:
					//unwrap means unwrap the ssl packet to get ssl handshake information
					sc.read(netIn);
					netIn.flip();
					hsStatus = doUnwrap();
					break;
				case NEED_WRAP:
					//wrap means wrap the app packet into an ssl packet to add ssl handshake information
					hsStatus = doWrap();
					sc.write(netOut);
					netOut.clear();
					break;
				case NOT_HANDSHAKING:
					//now it is not in a handshake or say byebye status. here it means handshake is over and ready for ssl talk
					sc.configureBlocking(false);//set the socket to unblocking mode
					sc.register(selector, SelectionKey.OP_READ|SelectionKey.OP_WRITE);//register the read and write event
					handshakeDone = true;
					break;
			}
		}
		
	}
	
	private HandshakeStatus doTask() {
		Runnable runnable;
		while ((runnable = sslEngine.getDelegatedTask()) != null)
		{
			System.out.println("\trunning delegated task...");
			runnable.run();
		}
		HandshakeStatus hsStatus = sslEngine.getHandshakeStatus();
		if (hsStatus == HandshakeStatus.NEED_TASK)
		{
			//throw new Exception("handshake shouldn't need additional tasks");
			System.out.println("handshake shouldn't need additional tasks");
		}
		System.out.println("\tnew HandshakeStatus: " + hsStatus);
		
		return hsStatus;
	}
	
	private HandshakeStatus doUnwrap() throws SSLException{
		HandshakeStatus hsStatus;
		do{//do unwrap until the state is change to "NEED_WRAP"
			SSLEngineResult engineResult = sslEngine.unwrap(netIn, appIn);
			log("server unwrap: ", engineResult);
			hsStatus = doTask();
		}while(hsStatus ==  SSLEngineResult.HandshakeStatus.NEED_UNWRAP && netIn.remaining()>0);
		System.out.println("\tnew HandshakeStatus: " + hsStatus);
		netIn.clear();
		return hsStatus;
	}
	
	private HandshakeStatus doWrap() throws SSLException{
		HandshakeStatus hsStatus;
		SSLEngineResult engineResult = sslEngine.wrap(appOut, netOut);
		log("server wrap: ", engineResult);
		hsStatus = doTask();
		System.out.println("\tnew HandshakeStatus: " + hsStatus);
		netOut.flip();
		return hsStatus;
	}
	
	//close an ssl talk, similar to the handshake steps
	private void doSSLClose(SelectionKey key) throws IOException {
		SocketChannel sc = (SocketChannel) key.channel();
		key.cancel();
		
		try
		{
			sc.configureBlocking(true);
		} catch (IOException e)
		{
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		HandshakeStatus hsStatus = sslEngine.getHandshakeStatus();
		while(handshakeDone) {
			switch(hsStatus) {
			case FINISHED:
				
				break;
			case NEED_TASK:
				hsStatus = doTask();
				break;
			case NEED_UNWRAP:
				sc.read(netIn);
				netIn.flip();
				hsStatus = doUnwrap();
				break;
			case NEED_WRAP:
				hsStatus = doWrap();
				sc.write(netOut);
				netOut.clear();
				break;
			case NOT_HANDSHAKING:
				handshakeDone = false;
				sc.close();
				break;
			}
		}
	}
	
	
	
	public static void main(String[] args) {
		SSLServer sns = new SSLServer();
		sns.selecting();
	}
}
