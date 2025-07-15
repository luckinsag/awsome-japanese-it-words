package com.example.itwordslearning.entity;

/**
 * Word 实体类，用于表示一个词汇的多语言信息。
 * 包括：日语原词、中文翻译、英文翻译及其分类。
 */
public class Word {

	// 单词ID（主键，用于唯一标识一个词条）
	private Integer wordId;

	// 日语词汇（原始词）
	private String japanese;

	// 中文翻译
	private String chinese;

	// 英文翻译
	private String english;

	// 分类，例如“名词”、“动词”、“形容词”等
	private String category;

	// 获取词汇ID
	public Integer getWordId() {
		return wordId;
	}

	// 设置词汇ID
	public void setWordId(Integer wordId) {
		this.wordId = wordId;
	}

	// 获取日语词汇
	public String getJapanese() {
		return japanese;
	}

	// 设置日语词汇
	public void setJapanese(String japanese) {
		this.japanese = japanese;
	}

	// 获取中文翻译
	public String getChinese() {
		return chinese;
	}

	// 设置中文翻译
	public void setChinese(String chinese) {
		this.chinese = chinese;
	}

	// 获取英文翻译
	public String getEnglish() {
		return english;
	}

	// 设置英文翻译
	public void setEnglish(String english) {
		this.english = english;
	}

	// 获取词汇分类
	public String getCategory() {
		return category;
	}

	// 设置词汇分类
	public void setCategory(String category) {
		this.category = category;
	}
	
	
	
	@Override
	public String toString() {
		return "Word{" + "wordId=" + wordId + ", japanese='" + japanese + '\'' + ", chinese='" + chinese + '\''
				+ ", english='" + english + '\'' + ", category='" + category + '\'' + '}';
	}

}
