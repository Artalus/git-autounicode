# git-autounicode
A Git pre-commit hook for automatic encoding files to UTF-8


# Prelude

While working on several projects taking place on Windows with git-server placed on Linux, I've usually got frustrated when we would create some source file, edit and commit it a bit, and then suddenly realize that it was created in ANSI, while the rest of the project is encoded in UTF-8. As such, the commit diffs would go crazy trying to comprehend several encodings on one list of files. And there usualy would be some "Fixed encoding" commits here and there.

At some point I've decided *"welp, if Git isn't smart enough to have something like `core.autoUTF8`, I'll just have to go with some tool to encode everything automatically from time to time"*. At first, it was a Python script launched from Notepad++. Then, at some point, I've suddenly learned about git hooks. And it opened a whole new world of opportunities...

# What it does

The point is really simple:
 - you make a commit;
 - the script checks all the new and changed files that are being commited;
 - if the file is not encoded in UTF-8, the script tries to encode it;
 - if at least one file was affected - the script aborts commit to allow user to check if everything is alright.

# How to install

 0. Make sure that your Git have access to `perl` and `iconv` tools
 1. Put `pre-commit.pl` into your repository root (the folder which cotains hidden `.git` subdir)
 2. Put pre-commit` into `.git/hooks`

# How to use

 - The `pre-commit` file serves as a simple hook that launches Perl script and aborts commit if needed.
 - The `pre-commit.pl` is the main body of the script.
 
It will launch automatically each time you make a commit. It ***will not*** make any changes to indexed files and ***will not*** apply the changes in encoding automatically: so you will have a chance to check the files in question and then `git add` or `git reset` them manually.

If the script prevents you from making a commit when you **re-e-eally** think it shouldn't -- you can use `git commit --no-verify` to surpass the pre-commit hook.

***Be advised*** when using this hook if you have non-Unicode symbols directly in your code (i.e. with `MessageBox.Show("Ошибка!")`), especially on Windows applications.

# Known issues

- If the file being encoded is *already* a mess of encodings, it will probably make things even worse
- Though the script should ignore binary files, on a rare occasion it may be triggered by something that is not recognized as binary file. If such is the case, you can revert the changes and use `--no-verify` option during the commit. You can also try to manually mark such files as binary using `.gitattributes`
- The script will emit an error if a file is staged for commit but is deleted from working copy.
