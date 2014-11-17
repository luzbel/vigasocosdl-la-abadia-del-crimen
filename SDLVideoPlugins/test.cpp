extern "C" void createPlugin(const char *name,void**a);

int main()
{
	void **a;
	createPlugin("win8",a);
	return 0;
}
