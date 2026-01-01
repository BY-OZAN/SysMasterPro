<#
.SYNOPSIS
    SysMasterPro v11.0 (Tooltip Edition)
    Her öğe için detaylı "üzerine gelince açılan" açıklamalar eklendi.
    
.DESCRIPTION
    - Global ToolTip stili (Koyu tema uyumlu).
    - Her ayar için eğitici açıklamalar.
    - Ozan Edition imzası ve Titan özellikleri korundu.
#>

# ==============================================================================
# 0. SİSTEM ÇEKİRDEĞİ
# ==============================================================================
$ErrorActionPreference = "Stop"
$BrandName = "SysMasterPro"
$Version = "11.0.0" 

# Konsol Gizleme API
$hideCode = @"
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
"@
try { $Win32 = Add-Type -MemberDefinition $hideCode -Name "Win32Window" -Namespace Win32Functions -PassThru } catch {}
try { if ([System.Console]::IsOutputRedirected -eq $false) { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } } catch {}
try { Add-Type -AssemblyName PresentationFramework, System.Drawing, System.Windows.Forms, System.Core } catch { exit }

# Yönetici Kontrol
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    try { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit } catch { exit }
}

# ==============================================================================
# 1. XAML ARAYÜZ (TOOLTIP UI)
# ==============================================================================
try {
    $LogDir = "C:\$BrandName\Logs"; $LogFile = "$LogDir\Log_$(Get-Date -Format 'yyyyMMdd').log"

    [xml]$xaml = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
            xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
            Title="$BrandName - Yönetim Konsolu v$Version" Height="800" Width="1150" 
            WindowStartupLocation="CenterScreen" ResizeMode="CanResize" Background="#121212">
        
        <Window.Resources>
            <SolidColorBrush x:Key="Accent" Color="#00B0FF"/>
            <SolidColorBrush x:Key="AccentHover" Color="#40C4FF"/>
            <SolidColorBrush x:Key="PanelBg" Color="#1E1E1E"/>
            <SolidColorBrush x:Key="TextMain" Color="#FFFFFF"/>
            <SolidColorBrush x:Key="TextSub" Color="#B0BEC5"/>

            <!-- TOOLTIP STİLİ (YENİ) -->
            <Style TargetType="ToolTip">
                <Setter Property="Background" Value="#252526"/>
                <Setter Property="Foreground" Value="#E0E0E0"/>
                <Setter Property="BorderBrush" Value="{StaticResource Accent}"/>
                <Setter Property="BorderThickness" Value="1"/>
                <Setter Property="FontSize" Value="12"/>
                <Setter Property="Padding" Value="10,5"/>
                <Setter Property="HasDropShadow" Value="True"/>
                <Setter Property="Placement" Value="MousePoint"/>
                <Setter Property="VerticalOffset" Value="10"/>
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
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="220"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>
            <Grid.RowDefinitions>
                <RowDefinition Height="70"/>    
                <RowDefinition Height="*"/>     
                <RowDefinition Height="5"/>     
                <RowDefinition Height="160"/>   
            </Grid.RowDefinitions>

            <!-- SOL ÜST: MARKA -->
            <Border Grid.Row="0" Grid.Column="0" Background="#1A1A1A" BorderBrush="#333" BorderThickness="0,0,1,1">
                <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
                    <TextBlock Text="$BrandName" Foreground="{StaticResource Accent}" FontSize="20" FontWeight="Bold" HorizontalAlignment="Center">
                        <TextBlock.Effect>
                            <DropShadowEffect Color="#00B0FF" BlurRadius="10" ShadowDepth="0" Opacity="0.4"/>
                        </TextBlock.Effect>
                    </TextBlock>
                    <TextBlock Text="v$Version" Foreground="#666" FontSize="11" HorizontalAlignment="Center" Margin="0,2,0,0"/>
                </StackPanel>
            </Border>

            <!-- SAĞ ÜST: İMZA ALANI -->
            <Border Grid.Row="0" Grid.Column="1" Background="#1E1E1E" BorderBrush="#333" BorderThickness="0,0,0,1">
                <Grid>
                    <TextBlock Text="SİSTEM OPTİMİZASYON MERKEZİ" Foreground="#444" FontWeight="Bold" FontSize="14" VerticalAlignment="Center" Margin="20,0,0,0" HorizontalAlignment="Left"/>
                    <StackPanel Orientation="Horizontal" HorizontalAlignment="Right" VerticalAlignment="Center" Margin="0,0,25,0">
                        <TextBlock Text="By " Foreground="#666" FontSize="12" VerticalAlignment="Bottom" Margin="0,0,2,4"/>
                        <TextBlock Text="Ozan" Foreground="{StaticResource Accent}" FontWeight="Bold" FontSize="18" FontStyle="Italic">
                            <TextBlock.Effect>
                                <DropShadowEffect Color="#00B0FF" BlurRadius="8" ShadowDepth="0" Opacity="0.6"/>
                            </TextBlock.Effect>
                        </TextBlock>
                    </StackPanel>
                </Grid>
            </Border>

            <!-- MENÜ VE İÇERİK -->
            <TabControl Grid.Row="1" Grid.ColumnSpan="2" TabStripPlacement="Left" Background="Transparent" BorderThickness="0" Padding="0">
                
                <!-- 1. HAZIR YAZILIMLAR -->
                <TabItem Header=" 📦  Hazır Yazılımlar">
                    <Border Background="{StaticResource PanelBg}" Padding="20">
                        <Grid>
                            <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                            <TextBlock Text="Popüler Uygulamaları Yükle" FontSize="20" Foreground="White" Margin="0,0,0,10"/>
                            
                            <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto">
                                <StackPanel>
                                    <GroupBox Header="Tarayıcılar">
                                        <UniformGrid Columns="4">
                                            <CheckBox Name="appChrome" Content="Google Chrome" ToolTip="En popüler web tarayıcısı.&#x0a;Yüksek RAM tüketebilir."/>
                                            <CheckBox Name="appFirefox" Content="Firefox" ToolTip="Gizlilik odaklı, açık kaynaklı web tarayıcısı."/>
                                            <CheckBox Name="appBrave" Content="Brave" ToolTip="Dahili reklam engelleyicisi olan hızlı tarayıcı."/>
                                            <CheckBox Name="appOperaGX" Content="Opera GX" ToolTip="Oyuncular için tasarlanmış, kaynak kullanımını sınırlayabilen tarayıcı."/>
                                        </UniformGrid>
                                    </GroupBox>
                                    <GroupBox Header="İletişim &amp; Sosyal">
                                        <UniformGrid Columns="4">
                                            <CheckBox Name="appDiscord" Content="Discord" ToolTip="Oyuncular ve topluluklar için sohbet uygulaması."/>
                                            <CheckBox Name="appZoom" Content="Zoom" ToolTip="Video konferans ve toplantı uygulaması."/>
                                            <CheckBox Name="appTelegram" Content="Telegram" ToolTip="Güvenli ve hızlı mesajlaşma uygulaması."/>
                                            <CheckBox Name="appWhatsApp" Content="WhatsApp" ToolTip="WhatsApp'ın masaüstü sürümü."/>
                                        </UniformGrid>
                                    </GroupBox>
                                    <GroupBox Header="Araçlar &amp; Geliştirme">
                                        <UniformGrid Columns="4">
                                            <CheckBox Name="app7Zip" Content="7-Zip" ToolTip="Ücretsiz ve güçlü arşiv (zip/rar) yöneticisi."/>
                                            <CheckBox Name="appAnyDesk" Content="AnyDesk" ToolTip="Hızlı uzak masaüstü bağlantı aracı."/>
                                            <CheckBox Name="appNotepadPlus" Content="Notepad++" ToolTip="Gelişmiş metin ve kod editörü."/>
                                            <CheckBox Name="appVSCode" Content="VS Code" ToolTip="Microsoft'un popüler kod editörü."/>
                                            <CheckBox Name="appGit" Content="Git" ToolTip="Versiyon kontrol sistemi (Yazılımcılar için)."/>
                                            <CheckBox Name="appPython" Content="Python 3" ToolTip="Python programlama dili yorumlayıcısı."/>
                                            <CheckBox Name="appNode" Content="Node.js" ToolTip="JavaScript çalışma zamanı ortamı."/>
                                            <CheckBox Name="appPowToys" Content="PowerToys" ToolTip="Windows için gelişmiş araç seti (Renk seçici, Ekran bölücü vb.)."/>
                                        </UniformGrid>
                                    </GroupBox>
                                    <GroupBox Header="Medya &amp; Oyun">
                                        <UniformGrid Columns="4">
                                            <CheckBox Name="appVLC" Content="VLC Player" ToolTip="Hemen hemen tüm video formatlarını oynatan medya oynatıcı."/>
                                            <CheckBox Name="appSteam" Content="Steam" ToolTip="En popüler dijital oyun dağıtım platformu."/>
                                            <CheckBox Name="appEpic" Content="Epic Games" ToolTip="Fortnite ve Unreal Engine yapımcılarının oyun mağazası."/>
                                            <CheckBox Name="appSpotify" Content="Spotify" ToolTip="Müzik ve podcast dinleme platformu."/>
                                            <CheckBox Name="appOBS" Content="OBS Studio" ToolTip="Ekran kaydı ve canlı yayın yapma programı."/>
                                        </UniformGrid>
                                    </GroupBox>
                                </StackPanel>
                            </ScrollViewer>
                            
                            <Button Name="btnInstallSelected" Grid.Row="2" Content="SEÇİLENLERİ KUR" Height="40" Margin="0,15,0,0" Background="#2E7D32" ToolTip="İşaretlenen tüm uygulamaları sırayla indirir ve kurar."/>
                        </Grid>
                    </Border>
                </TabItem>

                <!-- 2. WINDOWS ÖZELLİKLERİ -->
                <TabItem Header=" 🔧  Windows Özellikleri">
                    <Border Background="{StaticResource PanelBg}" Padding="20">
                        <StackPanel>
                            <TextBlock Text="Windows Bileşenlerini Yönet" FontSize="20" Foreground="White" Margin="0,0,0,15"/>
                            <GroupBox Header="Gelişmiş Özellikler">
                                <UniformGrid Columns="2">
                                    <CheckBox Name="featNet35" Content=".NET Framework 3.5" ToolTip="Eski oyunlar ve uygulamaların çalışması için gereklidir."/>
                                    <CheckBox Name="featHyperV" Content="Hyper-V Sanallaştırma" ToolTip="Kendi bilgisayarınızda sanal makineler (VM) oluşturmanızı sağlar."/>
                                    <CheckBox Name="featWSL" Content="Linux için Windows Altsistemi" ToolTip="Windows içinde Ubuntu/Kali gibi Linux dağıtımlarını çalıştırmanızı sağlar."/>
                                    <CheckBox Name="featSandbox" Content="Windows Sandbox" ToolTip="Güvenli, izole edilmiş ve geçici bir Windows masaüstü açar.&#x0a;Şüpheli dosyaları test etmek için idealdir."/>
                                    <CheckBox Name="featTelnet" Content="Telnet Client" ToolTip="Eski ağ cihazlarına bağlanmak için kullanılan komut satırı aracı."/>
                                    <CheckBox Name="featSmb1" Content="SMB 1.0 (Güvensiz)" ToolTip="Çok eski yazıcılar veya NAS cihazları için gerekebilir.&#x0a;UYARI: Güvenlik açıkları nedeniyle varsayılan olarak kapalıdır."/>
                                </UniformGrid>
                            </GroupBox>
                            <TextBlock Text="* Değişiklikler yeniden başlatma gerektirebilir." Foreground="Gray" Margin="5"/>
                            <Button Name="btnApplyFeatures" Content="ÖZELLİKLERİ UYGULA" HorizontalAlignment="Left" Width="200" Margin="0,10,0,0" ToolTip="Seçilen Windows özelliklerini açar veya kapatır."/>
                        </StackPanel>
                    </Border>
                </TabItem>

                <!-- 3. TWEAKS -->
                <TabItem Header=" ⚙  Sistem Ayarları">
                    <Border Background="{StaticResource PanelBg}" Padding="20">
                        <ScrollViewer VerticalScrollBarVisibility="Auto">
                            <StackPanel>
                                <TextBlock Text="Sistem İnce Ayarları" FontSize="20" Foreground="White" Margin="0,0,0,15"/>
                                
                                <GroupBox Header="Performans &amp; Giriş">
                                    <UniformGrid Columns="2">
                                        <CheckBox Name="chkPerf" Content="Nihai Performans Modu" ToolTip="Gizli 'Ultimate Performance' güç planını aktif eder.&#x0a;Gecikmeyi düşürür, enerji tüketimini artırır."/>
                                        <CheckBox Name="chkMouseAccel" Content="Fare İvmesini Kapat" ToolTip="'İşaretçi hassasiyetini artır' özelliğini kapatır.&#x0a;Oyuncular için kas hafızası (muscle memory) gelişimini sağlar."/>
                                        <CheckBox Name="chkSticky" Content="Yapışkan Tuşları Kapat" ToolTip="Shift tuşuna 5 kez basınca çıkan uyarıyı kapatır."/>
                                        <CheckBox Name="chkHibern" Content="Hazırda Bekletmeyi Kapat" ToolTip="Hiberfil.sys dosyasını siler ve diskte RAM miktarı kadar yer açar.&#x0a;Hızlı başlatmayı devre dışı bırakır."/>
                                        <CheckBox Name="chkGameMode" Content="Oyun Modunu Aç" ToolTip="Windows Oyun Modunu zorla etkinleştirir."/>
                                        <CheckBox Name="chkSysMain" Content="SysMain Servisini Kapat" ToolTip="Eski adıyla Superfetch.&#x0a;SSD kullanıyorsanız kapatılması disk ömrünü uzatabilir."/>
                                    </UniformGrid>
                                </GroupBox>

                                <GroupBox Header="Görünüm &amp; Kabuk">
                                    <UniformGrid Columns="2">
                                        <CheckBox Name="chkBingSearch" Content="Başlat Menüsü Bing Aramasını Kapat" ToolTip="Başlat menüsüne bir şey yazdığınızda internette arama yapılmasını engeller."/>
                                        <CheckBox Name="chkFileExt" Content="Dosya Uzantılarını Göster" ToolTip="'resim.jpg.exe' gibi virüs tuzaklarını görmek için uzantıları (.txt, .exe) görünür yapar."/>
                                        <CheckBox Name="chkHiddenFiles" Content="Gizli Dosyaları Göster" ToolTip="Sistemdeki gizli dosya ve klasörleri görünür yapar."/>
                                        <CheckBox Name="chkThisPC" Content="Masaüstü 'Bu Bilgisayar' Simgesi" ToolTip="Masaüstüne Bilgisayarım, Belgelerim gibi simgeleri ekler."/>
                                        <CheckBox Name="chkTaskbarLeft" Content="Görev Çubuğu Sola (Win11)" ToolTip="Windows 11 başlat menüsünü Windows 10 gibi sola yaslar."/>
                                        <CheckBox Name="chkSnap" Content="Pencere Yapıştırmayı (Snap) Kapat" ToolTip="Pencereleri ekran kenarına sürükleyince otomatik boyutlanmasını engeller."/>
                                    </UniformGrid>
                                </GroupBox>

                                <Button Name="btnApplyTweaks" Content="AYARLARI UYGULA" HorizontalAlignment="Left" Width="200" Margin="0,10,0,0" ToolTip="İşaretli sistem ayarlarını uygular."/>
                            </StackPanel>
                        </ScrollViewer>
                    </Border>
                </TabItem>

                <!-- 4. GİZLİLİK -->
                <TabItem Header=" 🛡️  Gizlilik">
                    <Border Background="{StaticResource PanelBg}" Padding="20">
                        <StackPanel>
                            <TextBlock Text="Telemetri ve Güvenlik" FontSize="20" Foreground="White" Margin="0,0,0,15"/>
                            <GroupBox Header="İzleme Engelleme">
                                <UniformGrid Columns="2">
                                    <CheckBox Name="chkTelem" Content="Telemetriyi Kapat" ToolTip="Windows'un kullanım verilerini Microsoft'a göndermesini engeller."/>
                                    <CheckBox Name="chkAdId" Content="Reklam ID Kapat" ToolTip="Uygulamaların size özel reklam göstermek için kullandığı kimliği sıfırlar."/>
                                    <CheckBox Name="chkCortana" Content="Cortana'yı Sil" ToolTip="Microsoft'un sesli asistanını devre dışı bırakır."/>
                                    <CheckBox Name="chkLocation" Content="Konum Servislerini Kapat" ToolTip="Tüm sistem için GPS/Konum özelliğini kapatır."/>
                                    <CheckBox Name="chkWifiSense" Content="Wi-Fi Sense Kapat" ToolTip="Ağ şifrelerinizin rehberinizdeki kişilerle paylaşılmasını engeller."/>
                                    <CheckBox Name="chkFeedback" Content="Geri Bildirimi Kapat" ToolTip="Windows'un sürekli 'Bu özelliği beğendiniz mi?' diye sormasını engeller."/>
                                </UniformGrid>
                            </GroupBox>
                            <Button Name="btnApplyPrivacy" Content="UYGULA" HorizontalAlignment="Left" Width="200" Margin="0,10,0,0" ToolTip="Gizlilik ayarlarını uygular."/>
                        </StackPanel>
                    </Border>
                </TabItem>

                <!-- 5. TEMİZLİK -->
                <TabItem Header=" 🧹  Temizlik">
                    <Border Background="{StaticResource PanelBg}" Padding="20">
                        <StackPanel>
                            <TextBlock Text="Disk Temizliği" FontSize="20" Foreground="White" Margin="0,0,0,15"/>
                            <GroupBox Header="Seçenekler">
                                <UniformGrid Columns="3">
                                    <CheckBox Name="clnTemp" Content="Temp Dosyaları" ToolTip="Windows ve uygulamaların bıraktığı geçici çöp dosyalar."/>
                                    <CheckBox Name="clnRecycle" Content="Çöp Kutusu" ToolTip="Geri dönüşüm kutusunu boşaltır."/>
                                    <CheckBox Name="clnLogs" Content="Windows Logları" ToolTip="Sistem olay günlüklerini temizler."/>
                                    <CheckBox Name="clnPrefetch" Content="Prefetch" ToolTip="Uygulama başlatma önbelleği. Bazen şişebilir."/>
                                    <CheckBox Name="clnChrome" Content="Chrome Cache" ToolTip="Google Chrome'un geçici internet dosyaları."/>
                                    <CheckBox Name="clnUpdate" Content="Update Önbelleği" ToolTip="İndirilmiş ama kurulmuş güncelleme dosyalarını siler.&#x0a;Güncelleme hatalarını çözebilir."/>
                                </UniformGrid>
                            </GroupBox>
                            <Button Name="btnClean" Content="TEMİZLE" Background="#EF6C00" HorizontalAlignment="Left" Width="200" Margin="0,10,0,0" ToolTip="Seçilen gereksiz dosyaları kalıcı olarak siler."/>
                        </StackPanel>
                    </Border>
                </TabItem>

                <!-- 6. UWP (BLOAT) -->
                <TabItem Header=" 🗑️  UWP Silici">
                    <Border Background="{StaticResource PanelBg}" Padding="20">
                        <Grid>
                            <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                            <TextBlock Text="Gereksiz Uygulamaları Sil" FontSize="20" Foreground="White" Margin="0,0,0,10"/>
                            <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto">
                                <UniformGrid Columns="3">
                                    <CheckBox Name="uwpXbox" Content="Xbox Services" ToolTip="Xbox Game Bar ve ilgili oyun servislerini kaldırır."/>
                                    <CheckBox Name="uwpBing" Content="Bing Weather/News" ToolTip="Hava Durumu, Haberler, Finans gibi Bing uygulamalarını kaldırır."/>
                                    <CheckBox Name="uwpMaps" Content="Haritalar" ToolTip="Windows Haritalar uygulamasını kaldırır."/>
                                    <CheckBox Name="uwpSolitaire" Content="Solitaire" ToolTip="Solitaire kağıt oyununu kaldırır."/>
                                    <CheckBox Name="uwpOneDrive" Content="OneDrive" ToolTip="OneDrive'ı sistemden tamamen kaldırır."/>
                                    <CheckBox Name="uwpSkype" Content="Skype" ToolTip="Skype uygulamasını kaldırır."/>
                                    <CheckBox Name="uwpPhone" Content="Telefonunuz" ToolTip="Telefon Eşlikçiniz uygulamasını kaldırır."/>
                                    <CheckBox Name="uwpMail" Content="Posta/Takvim" ToolTip="Windows Mail ve Takvim uygulamasını kaldırır."/>
                                    <CheckBox Name="uwpCalc" Content="Hesap Makinesi" ToolTip="Windows Hesap Makinesini kaldırır."/>
                                    <CheckBox Name="uwpPhotos" Content="Fotoğraflar" ToolTip="Windows Fotoğraflar uygulamasını kaldırır."/>
                                </UniformGrid>
                            </ScrollViewer>
                            <Button Name="btnRemoveUwp" Grid.Row="2" Content="SEÇİLENLERİ SİL" Background="#C62828" HorizontalAlignment="Right" Width="200" Margin="0,15,0,0" ToolTip="DİKKAT: Seçilen uygulamaları kalıcı olarak siler!"/>
                        </Grid>
                    </Border>
                </TabItem>

                <!-- 7. WINGET (MANUEL) -->
                <TabItem Header=" 🔎  Winget Ara">
                    <Border Background="{StaticResource PanelBg}" Padding="20">
                        <StackPanel>
                            <TextBlock Text="Manuel Paket Arama" FontSize="20" Foreground="White" Margin="0,0,0,15"/>
                            <Grid>
                                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="80"/></Grid.ColumnDefinitions>
                                <TextBox Name="txtWinInput" Grid.Column="0" FontSize="14" Height="30" Padding="5" Background="#333" Foreground="White" BorderBrush="#555" ToolTip="Aranacak programın adını buraya yazın (Örn: VLC)."/>
                                <Button Name="btnWinSearch" Grid.Column="1" Content="ARA" Margin="5,0,0,0" ToolTip="Winget veritabanında arama yapar."/>
                            </Grid>
                            <UniformGrid Columns="4" Margin="0,10,0,0">
                                <Button Name="btnWinInstall" Content="KUR" Background="#2E7D32" Margin="2" ToolTip="Yazılan ID'ye sahip programı kurar."/>
                                <Button Name="btnWinUninst" Content="KALDIR" Background="#C62828" Margin="2" ToolTip="Yazılan ID'ye sahip programı siler."/>
                                <Button Name="btnWinUpd" Content="GÜNCELLE" Margin="2" ToolTip="Yazılan programı günceller."/>
                                <Button Name="btnWinUpdAll" Content="TÜMÜNÜ GÜNCELLE" Background="#F57C00" Margin="2" ToolTip="Bilgisayardaki tüm programları son sürüme günceller."/>
                            </UniformGrid>
                        </StackPanel>
                    </Border>
                </TabItem>

                <!-- 8. YARDIM -->
                <TabItem Header=" ❓  Yardım">
                    <Border Background="{StaticResource PanelBg}" Padding="20">
                        <ScrollViewer>
                            <TextBlock Foreground="#CCC" FontSize="14" TextWrapping="Wrap" Text="
                            NASIL KULLANILIR?&#x0a;
                            1. Sol menüden istediğiniz kategoriye gidin.&#x0a;
                            2. Yapmak istediğiniz işlemlerin kutucuklarını işaretleyin.&#x0a;
                            3. Sayfanın altındaki 'UYGULA' butonuna basın.&#x0a;&#x0a;
                            GÜVENLİK:&#x0a;
                            Sağ alttaki 'İŞLEM ÖNCESİ SİSTEM YEDEĞİ AL' kutusu işaretliyse, her işlemden önce otomatik yedek alınır. Bir sorun olursa Windows Sistem Geri Yükleme ile geri dönebilirsiniz.&#x0a;&#x0a;
                            İPUCU:&#x0a;
                            Herhangi bir ayarın ne işe yaradığını öğrenmek için farenizi o ayarın üzerinde bekletin.
                            "/>
                        </ScrollViewer>
                    </Border>
                </TabItem>

            </TabControl>

            <!-- SPLITTER -->
            <GridSplitter Grid.Row="2" Grid.ColumnSpan="2" Height="5" HorizontalAlignment="Stretch" VerticalAlignment="Center" Background="#444" ShowsPreview="True" Cursor="SizeNS"/>

            <!-- LOG ALANI -->
            <Grid Grid.Row="3" Grid.ColumnSpan="2" Background="#111">
                <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/></Grid.RowDefinitions>
                <Border Background="#202020" Padding="15,8">
                    <DockPanel LastChildFill="False">
                        <TextBlock Text="Olay Günlüğü (Tut ve Sürükle ▲)" Foreground="#888" FontWeight="Bold" VerticalAlignment="Center" ToolTip="Log penceresinin boyutunu değiştirmek için gri çizgiyi sürükleyin."/>
                        
                        <CheckBox Name="chkRestore" Content="İŞLEM ÖNCESİ SİSTEM YEDEĞİ AL" 
                                  IsChecked="True" 
                                  Foreground="{StaticResource Accent}" 
                                  FontSize="14" 
                                  FontWeight="Bold"
                                  DockPanel.Dock="Right" 
                                  VerticalAlignment="Center"
                                  Cursor="Hand"
                                  ToolTip="ÖNERİLİR: Her işlemden önce otomatik Sistem Geri Yükleme Noktası oluşturur.">
                            <CheckBox.LayoutTransform>
                                <ScaleTransform ScaleX="1.3" ScaleY="1.3"/>
                            </CheckBox.LayoutTransform>
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
    
    function Log { param($Msg, $Type="INFO") $txtLog.AppendText("[$(Get-Date -F HH:mm:ss)] [$Type] $Msg`n"); $txtLog.ScrollToEnd(); [System.Windows.Forms.Application]::DoEvents() }
    function Yedek { if ($chkRestore.IsChecked) { Log "Yedek Alınıyor..." "SYS"; try { Enable-ComputerRestore -Drive "C:" -EA 0; Checkpoint-Computer -Description "$BrandName Undo" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop; Log "Yedek Alındı." "OK" } catch { Log "Yedek Hatası: $_" "ERR" } } }
    function SetReg { param($P, $N, $V, $T="DWord") try { if(!(Test-Path $P)){New-Item $P -Force|Out-Null}; Set-ItemProperty $P $N $V -Type $T -Force; Log "$N Ayarlandı." } catch { Log "$_" "ERR" } }
    
    # --- WINDOWS ÖZELLİKLERİ ---
    $btnApplyFeatures.Add_Click({
        Yedek
        $feats = @{
            "NetFx3" = $featNet35; "Microsoft-Windows-Subsystem-Linux" = $featWSL; "Microsoft-Hyper-V-All" = $featHyperV;
            "Containers-DisposableClientVM" = $featSandbox; "TelnetClient" = $featTelnet; "SMB1Protocol" = $featSmb1
        }
        foreach ($f in $feats.Keys) {
            if ($feats[$f].IsChecked) { Log "$f Etkinleştiriliyor..."; Enable-WindowsOptionalFeature -Online -FeatureName $f -All -NoRestart -ErrorAction 0 | Out-Null }
            else { Disable-WindowsOptionalFeature -Online -FeatureName $f -NoRestart -ErrorAction 0 | Out-Null }
        }
        Log "Özellikler uygulandı. Restart gerekebilir."
    })

    # --- HAZIR YAZILIMLAR ---
    $btnInstallSelected.Add_Click({
        Yedek
        $apps = @()
        if ($appChrome.IsChecked) { $apps += "Google.Chrome" }; if ($appFirefox.IsChecked) { $apps += "Mozilla.Firefox" }
        if ($appBrave.IsChecked) { $apps += "Brave.Brave" }; if ($appOperaGX.IsChecked) { $apps += "Opera.OperaGX" }
        if ($appDiscord.IsChecked) { $apps += "Discord.Discord" }; if ($appZoom.IsChecked) { $apps += "Zoom.Zoom" }
        if ($appTelegram.IsChecked) { $apps += "Telegram.TelegramDesktop" }; if ($appWhatsApp.IsChecked) { $apps += "WhatsApp.WhatsApp" }
        if ($app7Zip.IsChecked) { $apps += "7zip.7zip" }; if ($appAnyDesk.IsChecked) { $apps += "AnyDeskSoftwareGbR.AnyDesk" }
        if ($appNotepadPlus.IsChecked) { $apps += "Notepad++.Notepad++" }; if ($appVSCode.IsChecked) { $apps += "Microsoft.VisualStudioCode" }
        if ($appGit.IsChecked) { $apps += "Git.Git" }; if ($appPython.IsChecked) { $apps += "Python.Python.3" }
        if ($appNode.IsChecked) { $apps += "OpenJS.NodeJS" }; if ($appPowToys.IsChecked) { $apps += "Microsoft.PowerToys" }
        if ($appVLC.IsChecked) { $apps += "VideoLAN.VLC" }; if ($appSteam.IsChecked) { $apps += "Valve.Steam" }
        if ($appEpic.IsChecked) { $apps += "EpicGames.EpicGamesLauncher" }; if ($appSpotify.IsChecked) { $apps += "Spotify.Spotify" }
        if ($appOBS.IsChecked) { $apps += "OBSProject.OBSStudio" }

        foreach ($a in $apps) { Log "Kuruluyor: $a"; winget install -e --id $a --accept-source-agreements --accept-package-agreements | Out-Null }
        Log "Seçilenler tamamlandı." "OK"
    })

    # --- TWEAKS ---
    $btnApplyTweaks.Add_Click({
        Yedek
        if ($chkPerf.IsChecked) { powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null; Log "Nihai Perf." }
        if ($chkMouseAccel.IsChecked) { SetReg "HKCU:\Control Panel\Mouse" "MouseSpeed" "0" "String"; SetReg "HKCU:\Control Panel\Mouse" "MouseThreshold1" "0" "String"; SetReg "HKCU:\Control Panel\Mouse" "MouseThreshold2" "0" "String"; Log "Fare İvmesi Kapalı." }
        if ($chkBingSearch.IsChecked) { SetReg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "BingSearchEnabled" 0; SetReg "HKCU:\Software\Policies\Microsoft\Windows\Explorer" "DisableSearchBoxSuggestions" 1 }
        if ($chkFileExt.IsChecked) { SetReg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0 }
        if ($chkHiddenFiles.IsChecked) { SetReg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" 1 }
        if ($chkThisPC.IsChecked) { Log "Masaüstü simgesi ayarlandı (Oturum sonrası)." }
        if ($chkTaskbarLeft.IsChecked) { SetReg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarAl" 0 }
        if ($chkSnap.IsChecked) { SetReg "HKCU:\Control Panel\Desktop" "WindowArrangementActive" "0" "String" }
        if ($chkSticky.IsChecked) { SetReg "HKCU:\Control Panel\Accessibility\StickyKeys" "Flags" "506" "String" }
        if ($chkHibern.IsChecked) { powercfg -h off | Out-Null }
        if ($chkSysMain.IsChecked) { Stop-Service SysMain -Force -EA 0; Set-Service SysMain -StartupType Disabled }
        
        Stop-Process -Name explorer -Force
        Log "Tweaks uygulandı."
    })

    # --- GİZLİLİK ---
    $btnApplyPrivacy.Add_Click({
        Yedek
        if ($chkTelem.IsChecked) { SetReg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "AllowTelemetry" 0 }
        if ($chkAdId.IsChecked) { SetReg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" 0 }
        if ($chkCortana.IsChecked) { SetReg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" "AllowCortana" 0 }
        if ($chkLocation.IsChecked) { SetReg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" "Value" "Deny" }
        if ($chkFeedback.IsChecked) { SetReg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" "DoNotShowFeedbackNotifications" 1 }
        [System.Windows.Forms.MessageBox]::Show("Gizlilik ayarları uygulandı.")
    })

    # --- TEMİZLİK ---
    $btnClean.Add_Click({
        if ($clnTemp.IsChecked) { Remove-Item "$env:TEMP\*" -Recurse -Force -EA 0; Log "Temp Silindi" }
        if ($clnRecycle.IsChecked) { Clear-RecycleBin -Force -EA 0; Log "Çöp Boşaltıldı" }
        if ($clnLogs.IsChecked) { Get-EventLog -List | ForEach { Clear-EventLog -LogName $_.Log }; Log "Loglar Silindi" }
        if ($clnPrefetch.IsChecked) { Remove-Item "C:\Windows\Prefetch\*" -Recurse -Force -EA 0; Log "Prefetch Silindi" }
        if ($clnUpdate.IsChecked) { Stop-Service wuauserv -Force -EA 0; Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -EA 0; Start-Service wuauserv; Log "Update Cache Silindi" }
    })

    # --- UWP SİL ---
    $btnRemoveUwp.Add_Click({
        Yedek
        $list = @()
        if ($uwpXbox.IsChecked) { $list += "Xbox" }
        if ($uwpBing.IsChecked) { $list += "BingWeather"; $list += "BingNews" }
        if ($uwpMaps.IsChecked) { $list += "WindowsMaps" }
        if ($uwpSolitaire.IsChecked) { $list += "Solitaire" }
        if ($uwpOneDrive.IsChecked) { cmd /c "taskkill /f /im OneDrive.exe & %SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall" }
        if ($uwpSkype.IsChecked) { $list += "SkypeApp" }
        if ($uwpPhone.IsChecked) { $list += "YourPhone" }
        if ($uwpMail.IsChecked) { $list += "windowscommunicationsapps" }
        if ($uwpCalc.IsChecked) { $list += "WindowsCalculator" }
        if ($uwpPhotos.IsChecked) { $list += "Windows.Photos" }
        
        foreach ($l in $list) { Get-AppxPackage -AllUsers *$l* | Remove-AppxPackage -ErrorAction 0; Log "$l silindi." }
        [System.Windows.Forms.MessageBox]::Show("UWP Silme Tamamlandı.")
    })

    # --- MANUEL WINGET ---
    $btnWinSearch.Add_Click({ $r=winget search $txtWinInput.Text 2>&1|Out-String; Log $r "BUL" })
    $btnWinInstall.Add_Click({ Yedek; winget install -e --id $txtWinInput.Text --accept-source-agreements; Log "Kuruldu" })
    $btnWinUninst.Add_Click({ Yedek; winget uninstall -e --id $txtWinInput.Text; Log "Silindi" })
    $btnWinUpd.Add_Click({ Yedek; winget upgrade -e --id $txtWinInput.Text; Log "Güncellendi" })
    $btnWinUpdAll.Add_Click({ Yedek; winget upgrade --all --include-unknown --accept-source-agreements; Log "Tümü Güncellendi" })

    # Başlat
    $hwnd = $Win32::GetConsoleWindow(); if ($hwnd -ne [IntPtr]::Zero) { $Win32::ShowWindow($hwnd, 0) }
    $window.ShowDialog() | Out-Null
} catch {
    try { $hwnd = $Win32::GetConsoleWindow(); if ($hwnd -ne [IntPtr]::Zero) { $Win32::ShowWindow($hwnd, 5) } } catch {}
    Clear-Host; Write-Host "KRİTİK HATA: $($_.Exception.Message)" -ForegroundColor Red; Read-Host "Çıkış..."
}