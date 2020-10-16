package com.bamboocloud.bam.oauthone.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;

/**
 * Author:Zhenggang
 * CreateTime:2018/10/30 18:22
 */
@Controller
public class OauthDemo {

	/**
	 * 认证地址、应用注册id、应用注册key 三个参数因环境不同而不同，建议改为从配置文件中读取
	 */
	//认证地址
	public static final String BASE_URL = "http://utuum.sd-gold.com:7021/idp/oauth2";
	//应用注册id
	public static final String CLIENT_ID = "ERM";
	//应用注册key
	public static final String CLIENT_SECRET = "ermsecret";

	//获取access_token的url
	public static final String GET_ACCESS_TOKEN_URL = BASE_URL + "/getToken";
	//获取用户信息的url
	public static final String GET_USERINFO_URL = BASE_URL + "/getUserInfo?client_id=" + CLIENT_ID + "&access_token=";


	/**
	 * 访问ip:port/root/redirectToAuth时，拼接并且重定向到
	 * http://utuum.sd-gold.com:7021/idp/oauth2/authorize?redirect_uri=ip:port/root/getAccountName&state=sso&client_id=ECD&response_type=code
	 */
	@RequestMapping("/redirectToAuth")
	public void reToAuth(HttpServletRequest request, HttpServletResponse response) {
		String url = request.getRequestURL().toString().replaceAll("/redirectToAuth", "/getAccountName");
		String re_url = BASE_URL + "/authorize?redirect_uri=" + url + "&state=sso&client_id=" + CLIENT_ID + "&response_type=code";
		try {
			response.sendRedirect(re_url);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/**
	 * 此方法最后取到账号acc的值后，需要各系统进行登录逻辑处理
	 * @param code 用户名和密码认证通过后返回的code，根据此值可以获取access_token,从而获取到用户或账号信息
	 * @return
	 */
	@ResponseBody
	@RequestMapping(value = "/getAccountName", method = RequestMethod.GET)
	public String getAccountName(@RequestParam(name = "code") String code) {
		String accessTokenParam = null;
		System.out.println("1).authorize code is：" + code);
		try {
			accessTokenParam = "client_id=" + URLEncoder.encode(this.CLIENT_ID, "UTF-8");
			accessTokenParam += "&client_secret=" + URLEncoder.encode(this.CLIENT_SECRET, "UTF-8");
			accessTokenParam += "&grant_type=" + URLEncoder.encode("authorization_code", "UTF-8");
			accessTokenParam += "&code=" + URLEncoder.encode(code, "UTF-8");
		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		String TokenString = getStringPost(this.GET_ACCESS_TOKEN_URL, accessTokenParam);

		if (TokenString == null || TokenString.equals("")) {
			System.out.println("cannot get tokenInfo");
			return null;
		}
		System.out.println("2).tokenInfo is: " + TokenString);
		String accessToken = getValueFromJson(TokenString, "access_token");
		String addressParam = this.GET_USERINFO_URL + accessToken;
		String userInfo = getStringGet(addressParam);
		if (userInfo == null || userInfo.equals("")) {
			System.out.println("cannot get userInfo");
			return null;
		}
		System.out.println("3).userInfo is :" + userInfo);
		String acc = getValueFromJson(userInfo, "spRoleList");
		if (acc == null || acc.equals("")) {
			System.out.println("cannot get acc");
			return null;
		}
		System.out.println("the acc is :" + acc);
		return "the acc is : " + acc;
	}


	public String getStringPost(String address, String content) {
		StringBuffer buffer = new StringBuffer();
		DataOutputStream out = null;
		BufferedReader reader = null;
		try {
			URL url = new URL(address);
			HttpURLConnection conn = (HttpURLConnection) url.openConnection();
			conn.setConnectTimeout(20000);//设置超时时间
			conn.setDoOutput(true);//设置连接是否可输出数据
			conn.setRequestMethod("POST");
			conn.setUseCaches(false);
			conn.setInstanceFollowRedirects(true);

			conn.connect();
			out = new DataOutputStream(conn.getOutputStream());

			out.writeBytes(content);
			out.flush();
			out.close();
			System.out.println("返回代码：" + conn.getResponseCode());
			if (conn.getResponseCode() == 200) {
				reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));
				String line = "";
				while ((line = reader.readLine()) != null) {
					buffer.append(line);
				}
				reader.close();
			}
		} catch (IOException e) {
			e.printStackTrace();
		} finally {

			if (out != null) {
				try {
					out.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
			if (reader != null) {
				try {
					reader.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return buffer.toString();
	}

	public String getStringGet(String address) {
		StringBuffer buffer = new StringBuffer();
		BufferedReader reader = null;
		try {
			URL url = new URL(address);
			HttpURLConnection conn = (HttpURLConnection) url.openConnection();
			conn.connect();
			reader = new BufferedReader(new InputStreamReader(conn.getInputStream(), "UTF-8"));
			String line = "";
			while ((line = reader.readLine()) != null) {
				buffer.append(line);
			}
			reader.close();
		} catch (MalformedURLException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (reader != null) {
				try {
					reader.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		return buffer.toString();
	}


	/**
	 *
	 * @param jsonString json字符串
	 * @param key	键值
	 * 此处解析json依赖jackson，可改为fastjson、gosn等
	 * @return
	 */
	public String getValueFromJson(String jsonString, String key) {
		ObjectMapper mapper = new ObjectMapper();
		String value = "";
		try {
			JsonNode rootNode = mapper.readTree(jsonString);
			JsonNode tempValue = rootNode.get(key);
			if (tempValue == null) {
				return value;
			}
			if (tempValue.isArray()) {
				if (tempValue.size() > 0) {
					value = tempValue.get(0).asText();
				}
			} else {
				value = tempValue.asText();
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
		return value;
	}

}
