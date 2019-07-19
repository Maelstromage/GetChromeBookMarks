# Makes it so you can run from just the PS1 file
Add-Type -AssemblyName PresentationCore, PresentationFramework, System.Windows.Forms

# This part puts the xaml into a variable 
# <Window… goes here.
[xml]$XAML  = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:my_first_xaml"
        Title="test" Height="350" Width="320">
    <Grid Margin="0,0,0,0">
        <StackPanel Margin="0,0,0,0" Height="160" VerticalAlignment="Top">
            <TextBlock x:Name="formOutput" TextWrapping="Wrap" Text="Get Chrome Bookmarks" TextAlignment="Center" Background="#0000CC" Foreground="White" FontSize="12"  Height="160"/>
        </StackPanel>
        <StackPanel HorizontalAlignment="Left" Background="Blue"  Margin="0,160,0,0" Width="158">
            <Button x:Name="formButton" Content="Start" Background="Blue" Foreground="White" HorizontalAlignment="Left" Width="157.5" Height="150"/>
        </StackPanel>
        <TextBox x:Name="formInput" Margin="157.5,160,0,0" Background="#0000AA" AcceptsReturn="True" Foreground="White"/>

    </Grid>
</Window>
"@


# This part creates a reader object
$reader=(New-Object System.Xml.XmlNodeReader  $xaml)

# This loads the reader
$Window=[Windows.Markup.XamlReader]::Load(  $reader )


# This Connect the Controls it goes through and makes a variable for anything that has "Name="

  $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")  | ForEach {

  New-Variable  -Name $_.Name -Value $Window.FindName($_.Name) -Force

  }

#Code goes here, like events
$folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
$creds = Get-Credential -Message "Please enter admin credentials"

$formButton.Add_Click({
    $comps = $formInput.text.Split("`n")
    
   

    $folderDialog.Description = "Please select a folder for where files will be saved."
    $folderDialog.ShowDialog() | Out-Null

    Write-host $folderDialog.SelectedPath
    foreach($cComp in $comps){
        $folders = ""
        $folders = Invoke-Command -ComputerName $cComp -Credential $creds {Get-ChildItem -Path "C:\users\"}
        foreach($cfolder in $folders.name){
            if($cfolder -eq "Public"){continue}
            if($cfolder -contains "Admini"){continue}
            $cPath = "\\$cComp\C$\users\$cfolder\AppData\Local\Google\Chrome\User Data\Default\bookmarks"
            write-host $cPath
            $cBookmark = Invoke-Command -ComputerName $cComp -Credential $creds -ArgumentList $cPath {Get-Content -Path $args[0]}
            
            $filterBookmark = $cBookmark | findstr /C:"http"
            $selectedPath = $folderDialog.SelectedPath
            Add-Content "$selectedPath\$cfolder.txt" $filterBookmark


        }

    }
     
})


#this shows the window put it at the end.
$Null = $Window.ShowDialog()
