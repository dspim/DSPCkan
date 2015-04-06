## 安裝說明

請在安裝`devtools`套件之後執行：

```r
library(devtools)
install_github("ckanr", "wush978")
install_github("DSPCkan", "dspim")
```

目前DSPCkan需要使用非官方的ckanr套件

## 使用說明

DSPCkan目前只提供唯一功能：下載課程需要的檔案

如果需要其他功能，請到<https://github.com/dspim/DSPCkan/issues>許願

### 載入套件

```r
library(DSPCkan)
```

### 列出課程清單、查詢課程id

```r
download_course_materials()
```

此時會看到以下畫面：

請貼上在 <https://data.dsp.im/user/你的帳號> 中左下角看到的API-Key

並貼上如下：

在看到[OK]/Cancel之後請直接按下Enter

最後會看到課程清單：

請記目標課程的id

### 下載課程資料集

以下以目標課程id: `a1course`為例：

```r
download_course_materials("a1course")
```

輸入後，會要求輸入下載目標目錄：

如果不想輸入，可以直接Enter跳過，系統會下載至暫存目錄。

在看到[OK]/Cancel之後請直接按下Enter

在下載結束之後，會顯示下載的目標目錄：

之後可以輸入：

```r
browseURL("/private/var/folders/gg/g2b9zg5n59nb_93t3xnc8xtr0000gn/T/RtmpoU3MuJ")
```

來打開該目錄，檢視已經下載的檔案。

## 故障排除

如果在執行`download_course_materials`看到：

```
錯誤在function (type, msg, asError = TRUE)  : 
  transfer closed with outstanding read data remaining
```

這代表網路端可能出現不穩的錯誤，請直接重新執行指令`download_course_materials`。

如果看到：

```
錯誤在ckan_POST(url, "organization_show", body = body, ...) : 
  client error: (404) Not Found 
```

請檢查課程id是否有誤。

如果下載的檔案數量過少，請檢查 API-Key 是否有輸入錯誤。
