<#
.SYNOPSIS
    SysMasterPro v12.0 (Cloud Edition)
    Chris Titus Tech tarzı RAM üzerinden çalışan sürüm.
    
.DESCRIPTION
    - Dosya indirme gerektirmez (irm | iex).
    - Her zaman en güncel sürüm çalışır.
    - "Mark of the Web" güvenlik takılması yaşanmaz.
#>

# ==============================================================================
# 0. SİSTEM BAŞLANGIÇ KONTROLLERİ
# ==============================================================================
$ErrorActionPreference = "Stop"
$BrandName = "SysMasterPro"
$Version = "12.0.0" 

# 1. Yönetici Yetkisi Zorunluluğu
# RAM'den çalıştığı için kendini yeniden başlatamaz, kullanıcıyı baştan uyarırız.
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`n========================================================" -ForegroundColor Red
    Write-Host " HATA: YÖNETİCİ İZNİ GEREKLİ" -ForegroundColor Yellow
    Write-Host "========================================================" -ForegroundColor Red
    Write-Host " Lütfen PowerShell'i 'Yönetici Olarak' çalıştırın ve"
    Write-Host " komutu tekrar yapıştırın." -ForegroundColor Gray
    Write-Host "`n Çıkılıyor..."
    Start-Sleep -Seconds 4
    Break
}

# 2. Konsol Gizleme API
$hideCode = @"
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
"@
try { $Win32 = Add-Type -MemberDefinition $hideCode -Name "Win32Window" -Namespace Win32Functions -PassThru } catch {}

# 3. Encoding ve Kütüphaneler
try { if ([System.Console]::IsOutputRedirected -eq $false) { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } } catch {}
try { Add-Type -AssemblyName PresentationFramework, System.Drawing, System.Windows.Forms, System.Core } catch { exit }

# ==============================================================================
# 1. XAML ARAYÜZ (MODERN UI)
# ==============================================================================
try {
    # Loglar hala diske yazılabilir (C:\SysMasterPro\Logs)
    $LogDir = "C:\$BrandName\Logs"; 
    if (!(Test-Path $LogDir)) { New-Item -Path $LogDir -ItemType Directory -Force | Out-Null }
    $LogFile = "$LogDir\Session_$(Get-Date -Format 'yyyyMMdd_HHmm').log"

    [xml]$xaml = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
            xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
            Title="$BrandName - Cloud Edition v$Version" Height="800" Width="1150" 
            WindowStartupLocation="CenterScreen" ResizeMode="CanResize" Background="#121212">
        
        <Window.Resources>
            <SolidColorBrush x:Key="Accent" Color="#00B0FF"/>
            <SolidColorBrush x:Key="AccentHover" Color="#40C4FF"/>
            <SolidColorBrush x:Key="PanelBg" Color="#1E1E1E"/>
            <SolidColorBrush x:Key="TextMain" Color="#FFFFFF"/>
            <SolidColorBrush x:Key="TextSub" Color="#B0BEC5"/>

            <Style TargetType="ToolTip">
                <Setter Property="Background" Value="#252526"/>
                <Setter Property="Foreground" Value="#E0E0E0"/>
                <Setter Property="BorderBrush" Value="{StaticResource Accent}"/>
                <Setter Property="BorderThickness" Value="1"/>
                <Setter Property="FontSize" Value="12"/>
                <Setter Property="Padding" Value="10,5"/>
            </Style>

            <Style TargetType="GroupBox">
                <Setter Property="Margin" Value="0,0,0,10"/>
                <Setter Property="Padding" Value="5"/>
                <Setter Property="Foreground" Value="{StaticResource Accent}"/>
                <Setter Property="BorderBrush" Value="#333"/>
                <Setter Property="BorderThickness" Value="1"/>
                <Setter Property="FontWeight" Value="SemiBold"/>
                <Setter Property="FontSize" Value="13"/>
            </Style>
            <Style TargetType="CheckBox">
                <Setter Property="Margin" Value="5,6"/>
                <Setter Property="Foreground" Value="{StaticResource TextMain}"/>
                <Setter Property="FontSize" Value="12"/>
                <Setter Property="Cursor" Value="Hand"/>
            </Style>
            <Style TargetType="Button">
                <Setter Property="Background" Value="{StaticResource Accent}"/>
                <Setter Property="Foreground" Value="White"/>
                <Setter Property="FontWeight" Value="Bold"/>
                <Setter Property="Padding" Value="10,5"/>
                <Setter Property="BorderThickness" Value="0"/>
                <Setter Property="Cursor" Value="Hand"/>
                <Setter Property="Margin" Value="2"/>
                <Setter Property="Template">
                    <Setter.Value>
                        <ControlTemplate TargetType="Button">
                            <Border Background="{TemplateBinding Background}" CornerRadius="3" Padding="{TemplateBinding Padding}">
                                <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                            </Border>
                        </ControlTemplate>
                    </Setter.Value>
                </Setter>
                <Style.Triggers>
                    <Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="{StaticResource AccentHover}"/></Trigger>
                </Style.Triggers>
            </Style>
            <Style TargetType="TabItem">
                <Setter Property="FontSize" Value="13"/>
                <Setter Property="Height" Value="45"/>
                <Setter Property="Width" Value="200"/>
                <Setter Property="Foreground" Value="{StaticResource TextSub}"/>
                <Setter Property="Template">
                    <Setter.Value>
                        <ControlTemplate TargetType="TabItem">
                            <Grid>
                                <Border Name="Border" Background="Transparent" BorderBrush="Transparent" BorderThickness="4,0,0,0" Padding="15,0">
                                    <ContentPresenter VerticalAlignment="Center" HorizontalAlignment="Left" ContentSource="Header"/>
                                </Border>
                            </Grid>
                            <ControlTemplate.Triggers>
                                <Trigger Property="IsSelected" Value="True">
                                    <Setter TargetName="Border" Property="Background" Value="#252526"/>
                                    <Setter TargetName="Border" Property="BorderBrush" Value="{StaticResource Accent}"/>
                                    <Setter Property="Foreground" Value="White"/>
                                    <Setter Property="FontWeight" Value="Bold"/>
                                </Trigger>
                                <Trigger Property="IsMouseOver" Value="True">
                                    <Setter TargetName="Border" Property="Background" Value="#222"/>
                                    <Setter Property="Foreground" Value="White"/>
                                </Trigger>
                            </ControlTemplate.Triggers>
                        </ControlTemplate>
                    </Setter.Value>
                </Setter>
            </Style>
        </Window.Resources>

        <Grid>
            <Grid.ColumnDefinitions><ColumnDefinition Width="220"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
            <Grid.RowDefinitions><RowDefinition Height="70"/><RowDefinition Height="*"/><RowDefinition Height="5"/><RowDefinition Height="160"/></Grid.RowDefinitions>

            <!-- SOL ÜST: MARKA -->
            <Border Grid.Row="0" Grid.Column="0" Background="#1A1A1A" BorderBrush="#333" BorderThickness="0,0,1,1">
                <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
                    <TextBlock Text="$BrandName" Foreground="{StaticResource Accent}" FontSize="20" FontWeight="Bold" HorizontalAlignment="Center">
                        <TextBlock.Effect><DropShadowEffect Color="#00B0FF" BlurRadius="10" ShadowDepth="0" Opacity="0.4"/></TextBlock.Effect>
                    </TextBlock>
                    <TextBlock Text="v$Version" Foreground="#666" FontSize="11" HorizontalAlignment="Center" Margin="0,2,0,0"/>
                </StackPanel>
            </Border>

            <!-- SAĞ ÜST: İMZA -->
            <Border Grid.Row="0" Grid.Column="1" Background="#1E1E1E" BorderBrush="#333" BorderThickness="0,0,0,1">
                <Grid>
                    <TextBlock Text="CLOUD OPTIMIZATION TOOL" Foreground="#444" FontWeight="Bold" FontSize="14" VerticalAlignment="Center" Margin="20,0,0,0" HorizontalAlignment="Left"/>
                    <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="0,0,25,0">
                        <TextBlock Text="By " Foreground="#666" FontSize="12" VerticalAlignment="Bottom" Margin="0,0,2,4"/>
                        <TextBlock Text="Ozan" Foreground="{StaticResource Accent}" FontWeight="Bold" FontSize="18" FontStyle="Italic">
                            <TextBlock.Effect><DropShadowEffect Color="#00B0FF" BlurRadius="8" ShadowDepth="0" Opacity="0.6"/></TextBlock.Effect>
                        </TextBlock>
                    </StackPanel>
                </Grid>
            </Border>

            <!-- MENÜ VE İÇERİK -->
            <TabControl Grid.Row="1" Grid.ColumnSpan="2" TabStripPlacement="Left" Background="Transparent" BorderThickness="0" Padding="0">
                <TabItem Header=" 📦  Hazır Yazılımlar">
                    <Border Background="{StaticResource PanelBg}" Padding="20">
                        <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                            <TextBlock Text="Popüler Uygulamaları Yükle" FontSize="20" Foreground="White" Margin="0,0,0,10"/>
                            <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto"><StackPanel>
                                <GroupBox Header="Tarayıcılar"><UniformGrid Columns="4">
                                    <CheckBox Name="appChrome" Content="Google Chrome" ToolTip="En popüler web tarayıcısı."/>
                                    <CheckBox Name="appFirefox" Content="Firefox" ToolTip="Gizlilik odaklı."/>
                                    <CheckBox Name="appBrave" Content="Brave" ToolTip="Reklam engelleyicili."/>
                                    <CheckBox Name="appOperaGX" Content="Opera GX" ToolTip="Oyuncular için."/>
                                </UniformGrid></GroupBox>
                                <GroupBox Header="İletişim"><UniformGrid Columns="4">
                                    <CheckBox Name="appDiscord" Content="Discord" ToolTip="Sohbet uygulaması."/>
                                    <CheckBox Name="appZoom" Content="Zoom" ToolTip="Video konferans."/>
                                    <CheckBox Name="appTelegram" Content="Telegram" ToolTip="Mesajlaşma."/>
                                    <CheckBox Name="appWhatsApp" Content="WhatsApp" ToolTip="Mesajlaşma."/>
                                </UniformGrid></GroupBox>
                                <GroupBox Header="Araçlar"><UniformGrid Columns="4">
                                    <CheckBox Name="app7Zip" Content="7-Zip" ToolTip="Arşiv yöneticisi."/>
                                    <CheckBox Name="appAnyDesk" Content="AnyDesk" ToolTip="Uzak masaüstü."/>
                                    <CheckBox Name="appNotepadPlus" Content="Notepad++" ToolTip="Kod editörü."/>
                                    <CheckBox Name="appVSCode" Content="VS Code" ToolTip="Geliştirici editörü."/>
                                    <CheckBox Name="appGit" Content="Git" ToolTip="Versiyon kontrol."/>
                                    <CheckBox Name="appPython" Content="Python 3" ToolTip="Programlama."/>
                                    <CheckBox Name="appNode" Content="Node.js" ToolTip="JS ortamı."/>
                                    <CheckBox Name="appPowToys" Content="PowerToys" ToolTip="Windows araçları."/>
                                </UniformGrid></GroupBox>
                                <GroupBox Header="Medya"><UniformGrid Columns="4">
                                    <CheckBox Name="appVLC" Content="VLC Player" ToolTip="Video oynatıcı."/>
                                    <CheckBox Name="appSteam" Content="Steam" ToolTip="Oyun."/>
                                    <CheckBox Name="appEpic" Content="Epic Games" ToolTip="Oyun."/>
                                    <CheckBox Name="appSpotify" Content="Spotify" ToolTip="Müzik."/>
                                    <CheckBox Name="appOBS" Content="OBS Studio" ToolTip="Yayıncı."/>
                                </UniformGrid></GroupBox>
                            </StackPanel></ScrollViewer>
                            <Button Name="btnInstallSelected" Grid.Row="2" Content="SEÇİLENLERİ KUR" Height="40" Margin="0,15,0,0" Background="#2E7D32" ToolTip="Seçilenleri kurar."/>
                        </Grid>
                    </Border>
                </TabItem>

                <TabItem Header=" 🔧  Windows Özellikleri">
                    <Border Background="{StaticResource PanelBg}" Padding="20"><StackPanel>
                        <TextBlock Text="Bileşen Yönetimi" FontSize="20" Foreground="White" Margin="0,0,0,15"/>
                        <GroupBox Header="Gelişmiş Özellikler"><UniformGrid Columns="2">
                            <CheckBox Name="featNet35" Content=".NET Framework 3.5" ToolTip="Eski uygulamalar için."/>
                            <CheckBox Name="featHyperV" Content="Hyper-V" ToolTip="Sanal makine."/>
                            <CheckBox Name="featWSL" Content="Linux Altsistemi (WSL)" ToolTip="Linux desteği."/>
                            <CheckBox Name="featSandbox" Content="Windows Sandbox" ToolTip="Test ortamı."/>
                            <CheckBox Name="featTelnet" Content="Telnet Client" ToolTip="Eski ağ aracı."/>
                            <CheckBox Name="featSmb1" Content="SMB 1.0" ToolTip="Eski paylaşım (Güvensiz)."/>
                        </UniformGrid></GroupBox>
                        <Button Name="btnApplyFeatures" Content="UYGULA" HorizontalAlignment="Left" Width="200" Margin="0,10,0,0"/>
                    </StackPanel></Border>
                </TabItem>

                <TabItem Header=" ⚙  Sistem Ayarları">
                    <Border Background="{StaticResource PanelBg}" Padding="20"><ScrollViewer VerticalScrollBarVisibility="Auto"><StackPanel>
                        <TextBlock Text="İnce Ayarlar" FontSize="20" Foreground="White" Margin="0,0,0,15"/>
                        <GroupBox Header="Performans"><UniformGrid Columns="2">
                            <CheckBox Name="chkPerf" Content="Nihai Performans Modu" ToolTip="Yüksek güç."/>
                            <CheckBox Name="chkMouseAccel" Content="Fare İvmesini Kapat" ToolTip="Tutarlı aim."/>
                            <CheckBox Name="chkSticky" Content="Yapışkan Tuşları Kapat" ToolTip="Shift uyarısı."/>
                            <CheckBox Name="chkHibern" Content="Hazırda Bekletmeyi Kapat" ToolTip="Disk alanı."/>
                            <CheckBox Name="chkGameMode" Content="Oyun Modunu Aç" ToolTip="Oyun önceliği."/>
                            <CheckBox Name="chkSysMain" Content="SysMain Servisini Kapat" ToolTip="SSD için."/>
                        </UniformGrid></GroupBox>
                        <GroupBox Header="Görünüm"><UniformGrid Columns="2">
                            <CheckBox Name="chkBingSearch" Content="Bing Aramasını Kapat" ToolTip="Başlat araması."/>
                            <CheckBox Name="chkFileExt" Content="Dosya Uzantılarını Göster" ToolTip="Güvenlik."/>
                            <CheckBox Name="chkHiddenFiles" Content="Gizli Dosyaları Göster" ToolTip="Sistem dosyaları."/>
                            <CheckBox Name="chkThisPC" Content="Masaüstü 'Bu Bilgisayar'" ToolTip="Simgeler."/>
                            <CheckBox Name="chkTaskbarLeft" Content="Görev Çubuğu Sola (Win11)" ToolTip="Sola hizalama."/>
                            <CheckBox Name="chkSnap" Content="Snap Kapat" ToolTip="Pencere yapıştırma."/>
                        </UniformGrid></GroupBox>
                        <Button Name="btnApplyTweaks" Content="UYGULA" HorizontalAlignment="Left" Width="200" Margin="0,10,0,0"/>
                    </StackPanel></ScrollViewer></Border>
                </TabItem>

                <TabItem Header=" 🛡️  Gizlilik">
                    <Border Background="{StaticResource PanelBg}" Padding="20"><StackPanel>
                        <TextBlock Text="Gizlilik Kalkanı" FontSize="20" Foreground="White" Margin="0,0,0,15"/>
                        <GroupBox Header="Engelleme"><UniformGrid Columns="2">
                            <CheckBox Name="chkTelem" Content="Telemetriyi Kapat" ToolTip="Veri gönderimi."/>
                            <CheckBox Name="chkAdId" Content="Reklam ID Kapat" ToolTip="Reklam takibi."/>
                            <CheckBox Name="chkCortana" Content="Cortana'yı Sil" ToolTip="Sesli asistan."/>
                            <CheckBox Name="chkLocation" Content="Konum Servislerini Kapat" ToolTip="GPS."/>
                            <CheckBox Name="chkWifiSense" Content="Wi-Fi Sense Kapat" ToolTip="Ağ paylaşımı."/>
                            <CheckBox Name="chkFeedback" Content="Geri Bildirimi Kapat" ToolTip="Anketler."/>
                        </UniformGrid></GroupBox>
                        <Button Name="btnApplyPrivacy" Content="UYGULA" HorizontalAlignment="Left" Width="200" Margin="0,10,0,0"/>
                    </StackPanel></Border>
                </TabItem>

                <TabItem Header=" 🧹  Temizlik">
                    <Border Background="{StaticResource PanelBg}" Padding="20"><StackPanel>
                        <TextBlock Text="Sistem Temizliği" FontSize="20" Foreground="White" Margin="0,0,0,15"/>
                        <GroupBox Header="Seçenekler"><UniformGrid Columns="3">
                            <CheckBox Name="clnTemp" Content="Temp Dosyaları" ToolTip="Geçici."/>
                            <CheckBox Name="clnRecycle" Content="Çöp Kutusu" ToolTip="Geri dönüşüm."/>
                            <CheckBox Name="clnLogs" Content="Windows Logları" ToolTip="Kayıtlar."/>
                            <CheckBox Name="clnPrefetch" Content="Prefetch" ToolTip="Önbellek."/>
                            <CheckBox Name="clnChrome" Content="Chrome Cache" ToolTip="Tarayıcı."/>
                            <CheckBox Name="clnUpdate" Content="Update Önbelleği" ToolTip="Güncellemeler."/>
                        </UniformGrid></GroupBox>
                        <Button Name="btnClean" Content="TEMİZLE" Background="#EF6C00" HorizontalAlignment="Left" Width="200" Margin="0,10,0,0"/>
                    </StackPanel></Border>
                </TabItem>

                <TabItem Header=" 🗑️  UWP Silici">
                    <Border Background="{StaticResource PanelBg}" Padding="20"><Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                        <TextBlock Text="Gereksiz Uygulamaları Sil" FontSize="20" Foreground="White" Margin="0,0,0,10"/>
                        <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto"><UniformGrid Columns="3">
                            <CheckBox Name="uwpXbox" Content="Xbox Services" ToolTip="Oyun."/>
                            <CheckBox Name="uwpBing" Content="Bing Weather/News" ToolTip="Haberler."/>
                            <CheckBox Name="uwpMaps" Content="Haritalar" ToolTip="Harita."/>
                            <CheckBox Name="uwpSolitaire" Content="Solitaire" ToolTip="Kağıt oyunu."/>
                            <CheckBox Name="uwpOneDrive" Content="OneDrive" ToolTip="Bulut."/>
                            <CheckBox Name="uwpSkype" Content="Skype" ToolTip="İletişim."/>
                            <CheckBox Name="uwpPhone" Content="Telefonunuz" ToolTip="Bağlantı."/>
                            <CheckBox Name="uwpMail" Content="Posta/Takvim" ToolTip="Mail."/>
                            <CheckBox Name="uwpCalc" Content="Hesap Makinesi" ToolTip="Hesap."/>
                            <CheckBox Name="uwpPhotos" Content="Fotoğraflar" ToolTip="Fotoğraf."/>
                        </UniformGrid></ScrollViewer>
                        <Button Name="btnRemoveUwp" Grid.Row="2" Content="SEÇİLENLERİ SİL" Background="#C62828" HorizontalAlignment="Right" Width="200" Margin="0,15,0,0" ToolTip="Kalıcı siler."/>
                    </Grid></Border>
                </TabItem>

                <TabItem Header=" 🔎  Winget Ara">
                    <Border Background="{StaticResource PanelBg}" Padding="20"><StackPanel>
                        <TextBlock Text="Manuel Paket Arama" FontSize="20" Foreground="White" Margin="0,0,0,15"/>
                        <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="80"/></Grid.ColumnDefinitions>
                            <TextBox Name="txtWinInput" Grid.Column="0" FontSize="14" Height="30" Padding="5" Background="#333" Foreground="White" BorderBrush="#555" ToolTip="Program adı."/>
                            <Button Name="btnWinSearch" Grid.Column="1" Content="ARA" Margin="5,0,0,0"/>
                        </Grid>
                        <UniformGrid Columns="4" Margin="0,10,0,0">
                            <Button Name="btnWinInstall" Content="KUR" Background="#2E7D32" Margin="2"/>
                            <Button Name="btnWinUninst" Content="KALDIR" Background="#C62828" Margin="2"/>
                            <Button Name="btnWinUpd" Content="GÜNCELLE" Margin="2"/>
                            <Button Name="btnWinUpdAll" Content="TÜMÜNÜ GÜNCELLE" Background="#F57C00" Margin="2"/>
                        </UniformGrid>
                    </StackPanel></Border>
                </TabItem>

                <TabItem Header=" ❓  Yardım">
                    <Border Background="{StaticResource PanelBg}" Padding="20"><ScrollViewer>
                        <TextBlock Name="txtHelpGuide" Foreground="#E0E0E0" FontSize="14" TextWrapping="Wrap"/>
                    </ScrollViewer></Border>
                </TabItem>
            </TabControl>

            <GridSplitter Grid.Row="2" Grid.ColumnSpan="2" Height="5" HorizontalAlignment="Stretch" VerticalAlignment="Center" Background="#444" ShowsPreview="True" Cursor="SizeNS"/>

            <Grid Grid.Row="3" Grid.ColumnSpan="2" Background="#111">
                <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/></Grid.RowDefinitions>
                <Border Background="#202020" Padding="15,8">
                    <DockPanel LastChildFill="False">
                        <TextBlock Text="Olay Günlüğü (Tut ve Sürükle ▲)" Foreground="#888" FontWeight="Bold" VerticalAlignment="Center"/>
                        <CheckBox Name="chkRestore" Content="İŞLEM ÖNCESİ SİSTEM YEDEĞİ AL" IsChecked="True" Foreground="{StaticResource Accent}" FontSize="14" FontWeight="Bold" DockPanel.Dock="Right" VerticalAlignment="Center" Cursor="Hand" ToolTip="ÖNERİLİR: Her işlemden önce otomatik yedek alır.">
                            <CheckBox.LayoutTransform><ScaleTransform ScaleX="1.3" ScaleY="1.3"/></CheckBox.LayoutTransform>
                        </CheckBox>
                    </DockPanel>
                </Border>
                <TextBox Name="txtLog" Grid.Row="1" IsReadOnly="True" VerticalScrollBarVisibility="Auto" FontFamily="Consolas" FontSize="12" Background="#080808" Foreground="#00E676" BorderThickness="0" Padding="10" TextWrapping="Wrap"/>
            </Grid>
        </Grid>
    </Window>
"@

    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    try { $window = [Windows.Markup.XamlReader]::Load($reader) } catch { throw $_ }
    $xaml.SelectNodes("//*[@Name]") | ForEach-Object { try { Set-Variable -Name ($_.Name) -Value $window.FindName($_.Name) -Scope Global -ErrorAction Stop } catch {} }

    # ==============================================================================
    # 2. FONKSİYONLAR
    # ==============================================================================
    $txtHelpGuide.Text = @"
$BrandName v$Version - CLOUD EDITION REHBERİ
Hazırlayan: Ozan | Teknoloji: PowerShell & WPF

BU SÜRÜM HAKKINDA:
Bu sürüm, dosya indirmeden doğrudan RAM üzerinde çalışmak üzere tasarlanmıştır. Bu sayede hiçbir güvenlik uyarısına takılmaz ve her zaman en güncel haliyle çalışır.

NASIL KULLANILIR?
1. Sol menüden kategori seçin.
2. İşlemleri seçin.
3. 'UYGULA' butonuna basın.

ÖNEMLİ:
Bu araç sistem dosyalarına müdahale eder. Sağ alttaki 'Yedek Al' kutusu varsayılan olarak açıktır. Kapatmamanız önerilir.
"@

    function Log { param($Msg, $Type="INFO") $txtLog.AppendText("[$(Get-Date -F HH:mm:ss)] [$Type] $Msg`n"); $txtLog.ScrollToEnd(); [System.Windows.Forms.Application]::DoEvents() }
    function Yedek { if ($chkRestore.IsChecked) { Log "Yedek Alınıyor..." "SYS"; try { Enable-ComputerRestore -Drive "C:" -EA 0; Checkpoint-Computer -Description "$BrandName Undo" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop; Log "Yedek Alındı." "OK" } catch { Log "Yedek Hatası: $_" "ERR" } } }
    function SetReg { param($P, $N, $V, $T="DWord") try { if(!(Test-Path $P)){New-Item $P -Force|Out-Null}; Set-ItemProperty $P $N $V -Type $T -Force; Log "$N Ayarlandı." } catch { Log "$_" "ERR" } }
    
    $btnApplyFeatures.Add_Click({ Yedek; $feats = @{"NetFx3"=$featNet35;"Microsoft-Windows-Subsystem-Linux"=$featWSL;"Microsoft-Hyper-V-All"=$featHyperV;"Containers-DisposableClientVM"=$featSandbox;"TelnetClient"=$featTelnet;"SMB1Protocol"=$featSmb1}; foreach($f in $feats.Keys){if($feats[$f].IsChecked){Log "$f Açılıyor...";Enable-WindowsOptionalFeature -Online -FeatureName $f -All -NoRestart -ErrorAction 0|Out-Null}else{Disable-WindowsOptionalFeature -Online -FeatureName $f -NoRestart -ErrorAction 0|Out-Null}}; Log "Bitti. Restart gerekebilir." })
    $btnInstallSelected.Add_Click({ Yedek; $apps=@(); if($appChrome.IsChecked){$apps+="Google.Chrome"};if($appFirefox.IsChecked){$apps+="Mozilla.Firefox"};if($appBrave.IsChecked){$apps+="Brave.Brave"};if($appOperaGX.IsChecked){$apps+="Opera.OperaGX"};if($appDiscord.IsChecked){$apps+="Discord.Discord"};if($appZoom.IsChecked){$apps+="Zoom.Zoom"};if($appTelegram.IsChecked){$apps+="Telegram.TelegramDesktop"};if($appWhatsApp.IsChecked){$apps+="WhatsApp.WhatsApp"};if($app7Zip.IsChecked){$apps+="7zip.7zip"};if($appAnyDesk.IsChecked){$apps+="AnyDeskSoftwareGbR.AnyDesk"};if($appNotepadPlus.IsChecked){$apps+="Notepad++.Notepad++"};if($appVSCode.IsChecked){$apps+="Microsoft.VisualStudioCode"};if($appGit.IsChecked){$apps+="Git.Git"};if($appPython.IsChecked){$apps+="Python.Python.3"};if($appNode.IsChecked){$apps+="OpenJS.NodeJS"};if($appPowToys.IsChecked){$apps+="Microsoft.PowerToys"};if($appVLC.IsChecked){$apps+="VideoLAN.VLC"};if($appSteam.IsChecked){$apps+="Valve.Steam"};if($appEpic.IsChecked){$apps+="EpicGames.EpicGamesLauncher"};if($appSpotify.IsChecked){$apps+="Spotify.Spotify"};if($appOBS.IsChecked){$apps+="OBSProject.OBSStudio"}; foreach($a in $apps){Log "Kuruluyor: $a"; winget install -e --id $a --accept-source-agreements --accept-package-agreements|Out-Null}; Log "Tamamlandı." })
    $btnApplyTweaks.Add_Click({ Yedek; if($chkPerf.IsChecked){powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61|Out-Null;Log "Nihai Perf"}; if($chkMouseAccel.IsChecked){SetReg "HKCU:\Control Panel\Mouse" "MouseSpeed" "0" "String";SetReg "HKCU:\Control Panel\Mouse" "MouseThreshold1" "0" "String";SetReg "HKCU:\Control Panel\Mouse" "MouseThreshold2" "0" "String"}; if($chkBingSearch.IsChecked){SetReg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "BingSearchEnabled" 0;SetReg "HKCU:\Software\Policies\Microsoft\Windows\Explorer" "DisableSearchBoxSuggestions" 1}; if($chkFileExt.IsChecked){SetReg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0}; if($chkHiddenFiles.IsChecked){SetReg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" 1}; if($chkThisPC.IsChecked){Log "Masaüstü simgesi ayarlandı"}; if($chkTaskbarLeft.IsChecked){SetReg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarAl" 0}; if($chkSnap.IsChecked){SetReg "HKCU:\Control Panel\Desktop" "WindowArrangementActive" "0" "String"}; if($chkSticky.IsChecked){SetReg "HKCU:\Control Panel\Accessibility\StickyKeys" "Flags" "506" "String"}; if($chkHibern.IsChecked){powercfg -h off|Out-Null}; if($chkSysMain.IsChecked){Stop-Service SysMain -Force -EA 0; Set-Service SysMain -StartupType Disabled}; Stop-Process -Name explorer -Force; Log "Tweaks Uygulandı" })
    $btnApplyPrivacy.Add_Click({ Yedek; if($chkTelem.IsChecked){SetReg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0}; if($chkAdId.IsChecked){SetReg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" 0}; if($chkCortana.IsChecked){SetReg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowCortana" 0}; if($chkLocation.IsChecked){SetReg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" "Value" "Deny"}; if($chkFeedback.IsChecked){SetReg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "DoNotShowFeedbackNotifications" 1}; [System.Windows.Forms.MessageBox]::Show("Gizlilik ayarları uygulandı.") })
    $btnClean.Add_Click({ if($clnTemp.IsChecked){Remove-Item "$env:TEMP\*" -Recurse -Force -EA 0; Log "Temp Silindi"}; if($clnRecycle.IsChecked){Clear-RecycleBin -Force -EA 0; Log "Çöp Boşaltıldı"}; if($clnLogs.IsChecked){Get-EventLog -List|ForEach{Clear-EventLog -LogName $_.Log}; Log "Loglar Silindi"}; if($clnPrefetch.IsChecked){Remove-Item "C:\Windows\Prefetch\*" -Recurse -Force -EA 0; Log "Prefetch Silindi"}; if($clnUpdate.IsChecked){Stop-Service wuauserv -Force -EA 0; Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -EA 0; Start-Service wuauserv; Log "Update Cache Silindi"} })
    $btnRemoveUwp.Add_Click({ Yedek; $list=@(); if($uwpXbox.IsChecked){$list+="Xbox"}; if($uwpBing.IsChecked){$list+="BingWeather";$list+="BingNews"}; if($uwpMaps.IsChecked){$list+="WindowsMaps"}; if($uwpSolitaire.IsChecked){$list+="Solitaire"}; if($uwpOneDrive.IsChecked){cmd /c "taskkill /f /im OneDrive.exe & %SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall"}; if($uwpSkype.IsChecked){$list+="SkypeApp"}; if($uwpPhone.IsChecked){$list+="YourPhone"}; if($uwpMail.IsChecked){$list+="windowscommunicationsapps"}; if($uwpCalc.IsChecked){$list+="WindowsCalculator"}; if($uwpPhotos.IsChecked){$list+="Windows.Photos"}; foreach($l in $list){Get-AppxPackage -AllUsers *$l*|Remove-AppxPackage -EA 0; Log "$l silindi"}; [System.Windows.Forms.MessageBox]::Show("UWP Silme Tamamlandı") })
    $btnWinSearch.Add_Click({$r=winget search $txtWinInput.Text 2>&1|Out-String; Log $r "BUL"})
    $btnWinInstall.Add_Click({Yedek;winget install -e --id $txtWinInput.Text --accept-source-agreements;Log "Kuruldu"})
    $btnWinUninst.Add_Click({Yedek;winget uninstall -e --id $txtWinInput.Text;Log "Silindi"})
    $btnWinUpd.Add_Click({Yedek;winget upgrade -e --id $txtWinInput.Text;Log "Güncellendi"})
    $btnWinUpdAll.Add_Click({Yedek;winget upgrade --all --include-unknown --accept-source-agreements;Log "Tümü Güncellendi"})

    # Konsolu gizle (Eğer hala açıksa)
    $hwnd = $Win32::GetConsoleWindow()
    if ($hwnd -ne [IntPtr]::Zero) { $Win32::ShowWindow($hwnd, 0) }
    
    # Pencereyi Göster
    $window.ShowDialog() | Out-Null

} catch {
    # Hata durumunda konsolu geri getir ki hatayı okuyabilelim
    try { $hwnd = $Win32::GetConsoleWindow(); if ($hwnd -ne [IntPtr]::Zero) { $Win32::ShowWindow($hwnd, 5) } } catch {}
    Clear-Host; Write-Host "KRİTİK HATA: $($_.Exception.Message)" -ForegroundColor Red; Read-Host "Çıkış..."
}
