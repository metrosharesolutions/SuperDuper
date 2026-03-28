using System.Diagnostics;

internal class Program
{
	static async Task Main()
	{
		string dir = AppContext.BaseDirectory;

		string wlaExe = Path.Combine(dir, "wla-65816.exe");
		string linkExe = Path.Combine(dir, "wlalink.exe");
		string mainAsm = Path.Combine(dir, "main.asm");
		string linkfile = Path.Combine(dir, "linkfile");
		string mainObj = Path.Combine(dir, "main.obj");
		string romPath = Path.Combine(dir, "helloworld.sfc");

		if (!File.Exists(wlaExe)) throw new FileNotFoundException(wlaExe);
		if (!File.Exists(linkExe)) throw new FileNotFoundException(linkExe);
		if (!File.Exists(mainAsm)) throw new FileNotFoundException(mainAsm);
		if (!File.Exists(linkfile)) throw new FileNotFoundException(linkfile);

		if (File.Exists(mainObj)) File.Delete(mainObj);
		if (File.Exists(romPath)) File.Delete(romPath);

		await RunProcessAsync(wlaExe, $"-o \"{mainObj}\" \"{mainAsm}\"", dir);
		await RunProcessAsync(linkExe, $"-v -S \"{linkfile}\" \"{romPath}\"", dir);

		Console.WriteLine("Done: " + romPath);
	}

	static async Task RunProcessAsync(string exePath, string arguments, string workingDirectory)
	{
		var psi = new ProcessStartInfo
		{
			FileName = exePath,
			Arguments = arguments,
			WorkingDirectory = workingDirectory,
			UseShellExecute = false,
			RedirectStandardOutput = true,
			RedirectStandardError = true,
			CreateNoWindow = true
		};

		using var process = Process.Start(psi)!;

		string stdout = await process.StandardOutput.ReadToEndAsync();
		string stderr = await process.StandardError.ReadToEndAsync();

		await process.WaitForExitAsync();

		if (!string.IsNullOrWhiteSpace(stdout))
			Console.WriteLine(stdout);

		if (!string.IsNullOrWhiteSpace(stderr))
			Console.WriteLine(stderr);

		if (process.ExitCode != 0)
			throw new Exception($"Failed: {Path.GetFileName(exePath)}");
	}
}