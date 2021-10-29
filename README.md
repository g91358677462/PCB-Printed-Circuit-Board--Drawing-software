# PCB-繪圖軟體
<img src="https://github.com/g91358677462/PCB-Drawing-software/blob/main/assets/%E5%AF%A6%E7%BF%92%E4%BD%9C%E5%93%81-%E7%A8%8B%E5%BC%8F%E4%BB%8B%E9%9D%A2.PNG" width="50%" height="50%">
功能說明: 
1.解譯Gerber檔案: Gerber檔案是一種二維向量圖檔格式，描述印刷線路板圖像的標準格式，此功能將描繪出其電路結果。
2. 新增、刪減或查詢電路資訊: 每一條電路都記錄其資訊(e.g. 線路始末座標、孔型或線路寬, etc.)。

# 專業知識及技術
1. Gerber file
 這是一個從 PCB CAD 軟體輸出的資料檔做為光繪圖語言。1960 年代一家名
叫Gerber Scientific(現在稱Gerber System)專業做繪圖機的美國公司所發展出的
格式，爾後二十年，行銷於世界四十多個國家。幾乎所有 CAD 系統的發展，
也都依此格式做其 Output Data，直接輸入繪圖機就可繪出 Drawing 或 Film，
因此 Gerber Format 成了電子業界的公認標準。
2. RS-274D
 是 Gerber Format 的正式名稱，正確稱呼是 EIAS TANDARD
RS-274D(Electronic Industries Association)主要兩大組成：1.Function Code：如 G
codes, D codes, M codes 等。2.Coordinate data：定義圖像(imaging)。
3. RS-274X
是RS-274D的延伸版，除了RS-274D之Code以外，包括RS-274X Parameters，
或稱整個 extended Gerber format 他以兩個字母組合，定義了繪圖過程的一些特
性。
4. IPC-350
 IPC-350 是 IPC 發展出來的一套 neutral format，以很容易由 PCB CAD/CAM
產生，然後依此系統，PCB SHOP 再產生 NC Drill Program,Netlist,並可直接輸
入 Laser Plotter 繪製底片。
5. Laser Plotter
 輸入 Gerber format 或 IPC 350 format 以繪製 Artwork
<img src="https://github.com/g91358677462/PCB-Drawing-software/blob/main/assets/Laser%20Plotter.PNG" width="50%" height="50%">

6. Function Code
 G Codes
G04:表註解。
G54:執行換 Aperture。
 D Codes
D03:在目前的位置，執行快門閃一次。
D02:執行關閉快門的狀態下移動。
D01:執行打開快門的狀態下移動。
D10、D11、D12…:定義 Aperture1、Aperture2、Aperture3…。
 M Codes
MOIN:表單位為 inch。
MOMM:表單位為 millimeter。
M02:表全部執行結束。
7. Coordinate data
 EX:設定指令: FSLAX24Y24，其中FSLA:表頭省零(如果是FSTA:表尾省零)，
另外 X24:表 X 座標單位的讀法為整數兩位，小數四位，Y24 讀法同上。
EX:設定指令為 FSLAX24Y24，則座標 X-8522Y-9409 讀為(-0.8522,-0.9409)。
8. Aperture List and D-Codes
 舉個簡單實例來說明兩者關係, Aperture 的定義
 
<img src="https://github.com/g91358677462/PCB-Drawing-software/blob/main/assets/Aperture%20List%20and%20D-Codes.PNG" width="50%" height="50%">

<img src="https://github.com/g91358677462/PCB-Drawing-software/blob/main/assets/example%20result.PNG" width="50%" height="50%">

9. Lazarus
 Lazarus 是一個用於快速應用程式開發（RAD）的自由、跨平台的可視化集
成開發環境（IDE）。使用 Free Pascal 的編譯器，支持 Object Pascal 語言，與 Delphi
高度兼容，並被視作後者的自由軟體替代品。Lazarus 目前支持多種語言，包括中
文。軟體開發者可使用Lazarus創建原生的命令行與帶有圖形用戶界面的應用程式，
以及移動設備，Web 應用，Web 服務，可視化組件和各種函數庫。Lazarus 集成開
發環境和Free Pascal 編譯器支持多種作業系統，包括Windows、GNU/Linux 和Mac。
<img src="https://github.com/g91358677462/PCB-Drawing-software/blob/main/assets/Lazarus.PNG" width="50%" height="50%">
